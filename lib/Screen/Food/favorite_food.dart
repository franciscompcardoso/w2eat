import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:w2eat/Classes/food.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:w2eat/Screen/Food/favorite_list.dart';

class FavoriteFood extends StatefulWidget {
  const FavoriteFood({Key? key}) : super(key: key);

  @override
  FavoriteFoodState createState() => FavoriteFoodState();
}

class FavoriteFoodState extends State<FavoriteFood> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  Set<String> favorites = {};
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  bool isLastCard = false;

  @override
  void initState() {
    super.initState();
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    fetchFood();
  }

  Future<void> fetchFood() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final querySnapshot = await _firestore.collection('foods').get();

      if (querySnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print('Documents fetched successfully');
        }
        List<Food> newFoods = querySnapshot.docs.map((doc) {
          final data = doc.data();
          if (kDebugMode) {
            print('Document data: $data');
          }
          return Food.fromFirestore(data);
        }).toList();

        setState(() {
          for (var food in newFoods) {
            _swipeItems.add(SwipeItem(
              content: food,
              likeAction: () {
                addToFavorites(food);
              },
              nopeAction: () {
                // Nothing to do
              },
            ));
          }

          _swipeItems.add(SwipeItem(
            content: 'Novos Pratos em Breve',
            likeAction: () {},
            nopeAction: () {},
          ));

          _matchEngine = MatchEngine(swipeItems: _swipeItems);
          isLoading = false;
        });
      } else {
        if (kDebugMode) {
          print('No documents found');
        }
        setState(() {
          isLoading = false;
          hasMore = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching food: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addToFavorites(Food food) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);

        await userRef.update({
          'favorites': FieldValue.arrayUnion([
            {
              'title': food.title,
              'imageUrl': food.imageUrl,
            }
          ])
        });

        setState(() {
          favorites.add(food.title);
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error adding to favorites: $e');
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
        title: const Text('Comida Favorita'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            iconSize: 40,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteList()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _swipeItems.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0),
                    const Text(
                      'Escolha os seus Pratos Favoritos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Deslize para a Esquerda/Direita',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Stack(
                        children: [
                          SwipeCards(
                            matchEngine: _matchEngine,
                            itemBuilder: (BuildContext context, int index) {
                              final item = _swipeItems[index].content;

                              // Verifica se o item atual é o "Novas comidas em breve"
                              bool isEndCard = (item is String && item == 'Novos Pratos em Breve');

                              if (item is Food) {
                                final food = item;
                                return Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 300,
                                    height: 450, // Ajuste conforme necessário
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.0), // Ajuste o raio da borda conforme necessário
                                        side: const BorderSide(
                                          color: Colors.grey, // Cor da borda
                                          width: 2.0, // Largura da borda
                                        ),
                                      ),
                                      color: const Color.fromARGB(255, 251, 223, 223),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0), // Certifique-se de que o raio é o mesmo da borda
                                        child: Column(
                                          children: [
                                            Container(
                                              width: double.infinity, // Ajusta a largura para preencher o Card
                                              height: 350, // Ajuste a altura conforme necessário
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(food.imageUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0), // Adiciona espaço superior
                                              child: Text(
                                                food.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Roboto',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );




                              } else if (isEndCard) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 300,
                                    height: 400,
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                            onStackFinished: () {
                              // Lógica para quando a pilha terminar
                            },
                            itemChanged: (SwipeItem item, int index) {
                              if (index == _swipeItems.length - 1) {
                                setState(() {
                                  isLastCard = true;  // Marca o último cartão
                                });
                              } else {
                                setState(() {
                                  isLastCard = false; // Reseta se não for o último cartão
                                });
                              }
                            },
                            upSwipeAllowed: !isLastCard, // Desativa o swipe se for o "Novas comidas em breve"
                            fillSpace: false,
                          ),
                          if (isLastCard) // Adiciona um widget transparente para bloquear interações
                            Positioned.fill(
                              child: GestureDetector(
                                onPanUpdate: (details) {}, // Captura todos os gestos de swipe
                                onPanEnd: (details) {},
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 233, 180, 197),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.orange),
                              iconSize: 40,
                              onPressed: () {
                                if (!isLastCard) {
                                  _matchEngine.currentItem?.nope();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 40),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 233, 180, 197),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              iconSize: 40,
                              onPressed: () {
                                if (!isLastCard) {
                                  _matchEngine.currentItem?.like();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
