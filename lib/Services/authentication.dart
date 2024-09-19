import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<String?> get onAuthStateChanged => auth.authStateChanges().map(
        (User? user) => user?.uid,
      );

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _firestore.collection("users").doc(cred.user!.uid).set({
          'name': name,
          'uid': cred.user!.uid,
          'email': email,
        });

        res = "success";
      } else {
        res = "Please fill in all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Login User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Logout
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        print('Attempting to sign out...');
      }
      await auth.signOut();
      if (kDebugMode) {
        print('Signed out successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
