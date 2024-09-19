import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
final CollectionReference connectionsCollection = FirebaseFirestore.instance.collection('connections');

class FoodSelectionPage extends StatefulWidget {
  final String connectionId;
  final List<String> members;

  const FoodSelectionPage({super.key, required this.connectionId, required this.members});

  @override
  FoodSelectionPageState createState() => FoodSelectionPageState();
}

class FoodSelectionPageState extends State<FoodSelectionPage> {
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  bool isLoading = true;
  String errorMessage = '';
  List<String> selectedFoods = [];
  bool isLastCard = false;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      List<SwipeItem> swipeItems = [];
      for (String member in widget.members) {
        DocumentSnapshot userSnapshot = await usersCollection.doc(member).get();
        if (userSnapshot.exists) {
          var favorites = userSnapshot.get('favorites');
          if (favorites is List) {
            for (var item in favorites) {
              if (item is Map<String, dynamic> && item.containsKey('title') && item.containsKey('imageUrl')) {
                final String title = item['title'];
                final String imageUrl = item['imageUrl'];
                swipeItems.add(SwipeItem(
                  content: {'title': title, 'imageUrl': imageUrl},
                  likeAction: () {
                    _addToSelectedFoods(title);
                  },
                  nopeAction: () {},
                ));
              }
            }
          }
        }
      }

      // Adiciona o card de finalização
      swipeItems.add(SwipeItem(
        content: 'Novos Pratos em Breve',
        likeAction: () {},
        nopeAction: () {},
      ));

      setState(() {
        _swipeItems = swipeItems;
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _addToSelectedFoods(String food) {
    setState(() {
      if (!selectedFoods.contains(food)) {
        selectedFoods.add(food);
      }
    });
  }

  void _submitSelection() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    connectionsCollection.doc(widget.connectionId).update({
      'member_selections.$currentUserUid': selectedFoods,
    }).then((_) {
      _checkBothSelections();
    }).catchError((error) {
      if (kDebugMode) {
        print("Error submitting selection: $error");
      }
    });
  }

  void _checkBothSelections() async {
    try {
      DocumentSnapshot connectionSnapshot = await connectionsCollection.doc(widget.connectionId).get();
      Map<String, dynamic> memberSelections = connectionSnapshot.get('member_selections');

      if (memberSelections.keys.toSet().containsAll(widget.members)) {
        List<Set<String>> selections = memberSelections.values
            .map((selection) => selection is List ? Set<String>.from(selection) : <String>{})
            .toList();
        List<String> commonFoods = selections.reduce((value, element) => value.intersection(element)).toList();

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Comidas Selecionadas em Comum'),
              content: Text(commonFoods.join(', ')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error checking selections: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleção de Comidas'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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

                                if (item is Map<String, dynamic> && item.containsKey('title') && item.containsKey('imageUrl')) {
                                  final String title = item['title'];
                                  final String imageUrl = item['imageUrl'];

                                  return Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 300,
                                      height: 450,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          side: const BorderSide(
                                            color: Colors.grey,
                                            width: 2.0,
                                          ),
                                        ),
                                        color: const Color.fromARGB(255, 251, 223, 223),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 350,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(imageUrl),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
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
                                } else if (item is String && item == 'Novos Pratos em Breve') {
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
                                    isLastCard = true;
                                  });
                                } else {
                                  setState(() {
                                    isLastCard = false;
                                  });
                                }
                              },
                              upSwipeAllowed: !isLastCard,
                              fillSpace: false,
                            ),
                            if (isLastCard)
                              Positioned.fill(
                                child: GestureDetector(
                                  onPanUpdate: (details) {},
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
                      // Adicionando o botão de submissão na parte inferior
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _submitSelection,
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Submeter Seleção',
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
