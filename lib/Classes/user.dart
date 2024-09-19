// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String? photoURL;
 

  UserModel({required this.uid, required this.name, required this.email, this.photoURL,});

   Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photo': photoURL,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
     // ignore: unnecessary_null_comparison
     if (map == null) {
      throw ArgumentError('Map cannot be null');
     }
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      photoURL: map['photoURL'],
    );
  }
}

  class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    var snap = await _db.collection('users').doc(uid).get();
    if (snap.exists && snap.data() != null) {
      return UserModel.fromMap(snap.data()!);
    } else {
      return null; // Retorne null se o usuário não for encontrado
    }
  }  
}


Future<List<Map<String, dynamic>>> getFriendsList(String userId) async {
  List<Map<String, dynamic>> friendsList = [];

  try {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var friends = List<String>.from(userDoc.data()?['friends'] ?? []);

    for (var friendId in friends) {
      var friendDoc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        friendsList.add(friendDoc.data() as Map<String, dynamic>);
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao buscar lista de amigos: $e');
    }
  }

  return friendsList;
}


Future<void> removeFriend(String currentUserId, String friendId, BuildContext context) async {
    try {
      // Remove friendId da lista de amigos do currentUserId
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayRemove([friendId]),
      });

      // Remove currentUserId da lista de amigos do friendId
      await FirebaseFirestore.instance.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayRemove([currentUserId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amizade removida.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover amizade: $e')),
      );
    }
  }