import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:w2eat/Screen/Widgets/custom_textfield.dart';

class CreateConnectionPage extends StatefulWidget {
  const CreateConnectionPage({super.key});

  @override
  CreateConnectionPageState createState() => CreateConnectionPageState();
}

class CreateConnectionPageState extends State<CreateConnectionPage> {
  List<String> selectedFriends = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference connectionsCollection = FirebaseFirestore.instance.collection('connections');

  late Stream<List<DocumentSnapshot>> friendsStream;

  @override
  void initState() {
    super.initState();
    _initializeFriendsStream();
  }

  void _initializeFriendsStream() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    friendsStream = usersCollection
        .where('friends', arrayContains: currentUserUid)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conexão', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título da Conexão',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição da Conexão',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: friendsStream,
              builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                List<DocumentSnapshot> friends = snapshot.data!;

                return ListView(
                  children: friends.map((friend) {
                    return CheckboxListTile(
                      title: Text(friend['name']),
                      value: selectedFriends.contains(friend.id),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected!) {
                            selectedFriends.add(friend.id);
                          } else {
                            selectedFriends.remove(friend.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _sendConnectionRequest();
              },
              child: const Text('Enviar Pedido de Conexão'),
            ),
          ),
        ],
      ),
    );
  }

  void _sendConnectionRequest() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    List<String> validFriends = selectedFriends.where((friendId) => friendId != currentUserUid).toList();

    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    if (validFriends.isNotEmpty && title.isNotEmpty && description.isNotEmpty) {
      validFriends.add(currentUserUid);

      connectionsCollection.add({
        'members': validFriends,
        'status': 'pending',
        'member_selections': {},
        'requester': currentUserUid,
        'title': title,          // Adiciona o título
        'description': description, // Adiciona a descrição
      }).then((_) {
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar conexão: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos e selecione pelo menos um amigo para criar uma conexão.')),
      );
    }
  }
}
