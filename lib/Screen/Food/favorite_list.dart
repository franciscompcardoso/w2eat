import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:w2eat/Screen/Food/adicionar_comida.dart';

class FavoriteList extends StatefulWidget {
  const FavoriteList({Key? key}) : super(key: key);

  @override
  FavoriteListState createState() => FavoriteListState();
}

class FavoriteListState extends State<FavoriteList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> favoriteFoods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteFoods();
  }

  Future<void> fetchFavoriteFoods() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          List<dynamic> favorites = data['favorites'] ?? [];
          setState(() {
            favoriteFoods = List<Map<String, dynamic>>.from(favorites);
            isLoading = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching favorite foods: $e');
        }
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeFromFavorites(Map<String, dynamic> food) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);

        await userRef.update({
          'favorites': FieldValue.arrayRemove([food])
        });

        setState(() {
          favoriteFoods.remove(food);
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error removing from favorites: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print("No user is currently signed in.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Comidas Favoritas', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFoodPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteFoods.isEmpty
              ? const Center(child: Text('No favorites found'))
              : ListView.builder(
                  itemCount: favoriteFoods.length,
                  itemBuilder: (context, index) {
                    var food = favoriteFoods[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(food['imageUrl']),
                        title: Text(food['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromFavorites(food);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
