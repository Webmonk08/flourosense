# FluoroSense

FluoroSense is a mobile application designed to detect dental fluorosis using machine learning. It features a Flutter-based frontend and a FastAPI-based backend integrated with Supabase for authentication, data storage, and image hosting.

## Project Structure

- `fluorosense/`: Flutter mobile application.
- `backend/`: FastAPI server and ML inference logic.
- `dataset/`: (Optional) Dataset used for training.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python 3.9+](https://www.python.org/downloads/)
- [Supabase Account](https://supabase.com/)

---

## Backend Setup (FastAPI)

1.  **Navigate to the backend directory:**
    ```bash
    cd backend
    ```

2.  **Create a virtual environment:**
    ```bash
    python -m venv env
    source env/bin/activate  # On Windows: env\Scripts\activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Configure Environment Variables:**
    Create a `.env` file in the `backend/` directory with the following:
    ```env
    SUPABASE_URL=your_supabase_project_url
    SUPABASE_KEY=your_supabase_anon_key
    SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
    JWT_SECRET_KEY=your_random_secret_key
    ```

5.  **Run the server:**
    ```bash
    uvicorn app.main:app --reload
    ```
    The API will be available at `http://127.0.0.1:8000`.

---

## Frontend Setup (Flutter)

1.  **Navigate to the frontend directory:**
    ```bash
    cd fluorosense
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure API URL:**
    Update the `_baseUrl` in `lib/services/api_service.dart` if your backend is hosted elsewhere or if you are running on a physical device (use your local IP).

4.  **Run the application:**
    ```bash
    flutter run
    ```

---

## Database Schema (Supabase / PostgreSQL)

Run the following SQL in your Supabase SQL Editor to set up the required tables.

### 1. Users Table
Stores user profile information and authentication hashes.

```sql
CREATE TABLE users (
    email TEXT PRIMARY KEY,
    hashed_password TEXT NOT NULL,
    name TEXT,
    age TEXT,
    gender TEXT,
    water_source TEXT,
    toothpaste_type TEXT,
    user_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. Reports Table
Stores the results of fluorosis classifications.

```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES users(email),
    name TEXT NOT NULL,
    age TEXT NOT NULL,
    gender TEXT NOT NULL,
    water_source TEXT NOT NULL,
    toothpaste_type TEXT NOT NULL,
    milk_intake TEXT,
    sugar_levels TEXT,
    toothpaste_swallowing TEXT,
    classification TEXT NOT NULL,
    confidence FLOAT NOT NULL,
    image_url TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. Storage Configuration
Ensure you create a **public** storage bucket in Supabase named `user_images` to store the uploaded tooth images.

---

## ML Model
The backend uses a TFLite model located at `backend/assets/model.tflite`. Ensure this file and `backend/assets/labels.txt` are present before starting the server.
