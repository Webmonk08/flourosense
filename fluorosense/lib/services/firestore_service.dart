import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUser({
    required String name,
    required String age,
    required String gender,
    required String waterSource,
    required String toothpasteType,
    String? milkIntake,
    String? sugarLevels,
    String? toothpasteSwallowing,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'name': name,
        'age': age,
        'gender': gender,
        'waterSource': waterSource,
        'toothpasteType': toothpasteType,
        'milkIntake': milkIntake,
        'sugarLevels': sugarLevels,
        'toothpasteSwallowing': toothpasteSwallowing,
      });
    }
  }

  Future<void> addAnalysisResult({
    required String classification,
    required double confidence,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('analysis_results')
          .add({
        'classification': classification,
        'confidence': confidence,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}
