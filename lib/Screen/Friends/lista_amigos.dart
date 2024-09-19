import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:w2eat/Classes/User.dart';
import 'package:w2eat/Screen/Friends/pedidos_amizade.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({required this.currentUserId, Key? key}) : super(key: key);

  @override
  FriendsListPageState createState() => FriendsListPageState();
}

class FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, dynamic>> friendsList = [];
  List<Map<String, dynamic>> filteredFriendsList = [];
  bool isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFriendsList();
    user = _auth.currentUser!;
    searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriendsList() async {
    try {
      var friends = await getFriendsList(widget.currentUserId);
      setState(() {
        friendsList = friends;
        filteredFriendsList = friends;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar lista de amigos: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterFriends() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredFriendsList = friendsList.where((friend) {
        return friend['name'].toLowerCase().contains(query) ||
               friend['email'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _removeFriend(String userId, String friendId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendId])
      });

      await FirebaseFirestore.instance.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayRemove([userId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amigo removido com sucesso')),
      );

      // Atualiza a lista de amigos
      _fetchFriendsList();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao remover amigo: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover amigo')),
      );
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Amigos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FriendRequestsPage(currentUserId: user.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar amigos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                Expanded(
                  child: filteredFriendsList.isEmpty
                      ? const Center(child: Text('Você ainda não tem amigos.'))
                      : ListView.builder(
                          itemCount: filteredFriendsList.length,
                          itemBuilder: (context, index) {
                            var friendData = filteredFriendsList[index];

                            return ListTile(
                              title: Text(friendData['name'] ?? 'Nome desconhecido'),
                              subtitle: Text(friendData['email'] ?? 'E-mail desconhecido'),
                              leading: SizedBox(
                                width: 50, // Ajuste o tamanho conforme necessário
                                height: 50, // Ajuste o tamanho conforme necessário
                                child: friendData['photoURL'] != null
                                    ? Image.network(
                                        friendData['photoURL']!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.account_circle,
                                        size: 50, // Ajuste o tamanho do ícone para igualar o tamanho da imagem
                                      ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () async {
                                  await _removeFriend(widget.currentUserId, friendData['uid'], context);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}