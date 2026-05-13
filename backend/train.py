import tensorflow as tf
import os
import argparse
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Input, GlobalAveragePooling2D, Dense
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam

# --- Configuration ---
IMG_SIZE = (224, 224)
BATCH_SIZE = 32
INITIAL_EPOCHS = 10
FINE_TUNE_EPOCHS = 10
LEARNING_RATE = 0.0001

def build_model(num_classes, input_shape):
    """
    Builds a transfer learning model with MobileNetV2 as the base.
    """
    # Load the base model with pre-trained weights, excluding the top classification layer
    base_model = MobileNetV2(input_shape=input_shape, include_top=False, weights='imagenet')

    # Freeze the base model layers
    base_model.trainable = False

    # Create our new custom head
    inputs = Input(shape=input_shape)
    x = base_model(inputs, training=False)
    x = GlobalAveragePooling2D()(x)
    outputs = Dense(num_classes, activation='softmax')(x)

    # Combine the base model and the new head
    model = Model(inputs, outputs)
    
    return model, base_model

def compile_model(model, learning_rate):
    """
    Compiles the model with optimizer, loss function, and metrics.
    """
    model.compile(optimizer=Adam(learning_rate=learning_rate),
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])
    return model

def main(dataset_path, output_path):
    """
    Main function to run the training pipeline.
    """
    print(f"Loading dataset from: {dataset_path}")
    
    # --- 1. Data Preparation ---
    # Create data generators with augmentation for the training set
    train_datagen = ImageDataGenerator(
        rescale=1./255,
        rotation_range=40,
        width_shift_range=0.2,
        height_shift_range=0.2,
        shear_range=0.2,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode='nearest',
        validation_split=0.2  # Use 20% of data for validation
    )

    # Note: Validation generator should not have augmentation, only rescaling
    validation_datagen = ImageDataGenerator(rescale=1./255, validation_split=0.2)

    train_generator = train_datagen.flow_from_directory(
        dataset_path,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='training'
    )

    validation_generator = validation_datagen.flow_from_directory(
        dataset_path,
        target_size=IMG_SIZE,
        batch_size=BATCH_SIZE,
        class_mode='categorical',
        subset='validation'
    )
    
    num_classes = train_generator.num_classes
    print(f"Found {num_classes} classes: {list(train_generator.class_indices.keys())}")

    # --- 2. Build and Compile Model ---
    model, base_model = build_model(num_classes, IMG_SIZE + (3,)))
    model = compile_model(model, LEARNING_RATE)
    
    print("\n--- Initial Training (Frozen Base Model) ---")
    model.summary()
    
    # --- 3. Initial Training ---
    history = model.fit(
        train_generator,
        epochs=INITIAL_EPOCHS,
        validation_data=validation_generator
    )

    # --- 4. Fine-Tuning ---
    print("\n--- Starting Fine-Tuning (Unfreezing top layers) ---")
    base_model.trainable = True

    # Unfreeze from this layer onwards
    fine_tune_at = 100 
    for layer in base_model.layers[:fine_tune_at]:
        layer.trainable = False

    # Re-compile with a lower learning rate for fine-tuning
    model = compile_model(model, LEARNING_RATE / 10)
    model.summary()

    total_epochs = INITIAL_EPOCHS + FINE_TUNE_EPOCHS
    history_fine = model.fit(
        train_generator,
        epochs=total_epochs,
        initial_epoch=history.epoch[-1],
        validation_data=validation_generator
    )

    # --- 5. Convert and Save TFLite Model ---
    print("\n--- Converting model to TFLite ---")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    # Save the model
    tflite_model_path = os.path.join(output_path, 'model.tflite')
    with open(tflite_model_path, 'wb') as f:
        f.write(tflite_model)

    # Save the labels
    labels_path = os.path.join(output_path, 'labels.txt')
    with open(labels_path, 'w') as f:
        f.write('\n'.join(train_generator.class_indices.keys()))
        
    print(f"\nSuccessfully trained and saved model to: {tflite_model_path}")
    print(f"Labels saved to: {labels_path}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Train a dental fluorosis classification model.")
    parser.add_argument("--dataset_path", type=str, default="../dataset", help="Path to the dataset directory.")
    parser.add_argument("--output_path", type=str, default="assets", help="Path to save the tflite model and labels.")
    args = parser.parse_args()

    if not os.path.exists(args.output_path):
        os.makedirs(args.output_path)
        
    main(args.dataset_path, args.output_path)
