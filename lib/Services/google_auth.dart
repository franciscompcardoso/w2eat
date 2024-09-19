import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  // dont't gorget to add firebasea auth and google sign in package
  Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // O usuário cancelou o login
      return;
    }
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final UserCredential userCredential = await auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // O usuário está autenticado com sucesso
      if (kDebugMode) {
        print('Usuário logado: ${user.uid}');
      }
      // Aqui você deve chamar uma função para registrar os dados do usuário no Firestore
      await _registerUser(user);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao autenticar com o Google: $e');
    }
  }
}


Future<void> _registerUser(User user) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DocumentReference userDoc = firestore.collection('users').doc(user.uid);
  
  // Dados do usuário que você deseja salvar
  final Map<String, dynamic> userData = {
    'uid': user.uid,
    'email': user.email,
    'name': user.displayName,
    'photoURL': user.photoURL,
  };
  
  try {
    // Verifica se o documento já existe
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      // Cria um novo documento se ele não existir
      await userDoc.set(userData);
    } else {
      // Atualiza o documento existente
      await userDoc.update(userData);
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao registrar dados do usuário: $e');
    }
  }
}

// for sign out
  googleSignOut() async {
    await googleSignIn.signOut();
    auth.signOut();
  }
}