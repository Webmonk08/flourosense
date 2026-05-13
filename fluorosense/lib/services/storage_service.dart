import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _storage
          .ref()
          .child('user_images')
          .child(user.uid)
          .child('${DateTime.now().toIso8601String()}.jpg');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }
}
