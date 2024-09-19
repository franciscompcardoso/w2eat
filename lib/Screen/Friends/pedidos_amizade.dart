import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestsPage extends StatefulWidget {
  final String currentUserId;

  const FriendRequestsPage({required this.currentUserId, Key? key}) : super(key: key);

  @override
  FriendRequestsPageState createState() => FriendRequestsPageState();
}

class FriendRequestsPageState extends State<FriendRequestsPage> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendFriendRequest(String email) async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado!')),
        );
        return;
      }

      var toUserId = userSnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from': widget.currentUserId,
        'to': toUserId,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido de amizade enviado!')),
      );

      _emailController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar pedido.')),
      );
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String fromUserId) async {
    try {
      await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
        'status': 'accepted',
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).update({
        'friends': FieldValue.arrayUnion([fromUserId]),
      });

      await FirebaseFirestore.instance.collection('users').doc(fromUserId).update({
        'friends': FieldValue.arrayUnion([widget.currentUserId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amizade aceita!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao aceitar amizade.')),
      );
    }
  }

  Future<void> _declineFriendRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('friend_requests').doc(requestId).update({
        'status': 'declined',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amizade recusada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao recusar amizade.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de Amizade'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email do Usuário',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _sendFriendRequest(_emailController.text.trim());
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('friend_requests')
                  .where('to', isEqualTo: widget.currentUserId)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var requests = snapshot.data!.docs;

                if (requests.isEmpty) {
                  return const Center(child: Text('Não há pedidos de amizade pendentes.'));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index];
                    var fromUserId = request['from'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const ListTile(
                            title: Text('Carregando...'),
                          );
                        }

                        if (snapshot.data == null || !snapshot.data!.exists) {
                          return const ListTile(
                            title: Text('Solicitante não encontrado.'),
                          );
                        }

                        var fromUserData = snapshot.data!.data() as Map<String, dynamic>?;

                        if (fromUserData == null) {
                          return const ListTile(
                            title: Text('Dados do solicitante estão ausentes.'),
                          );
                        }

                        return ListTile(
                          title: Text(fromUserData['name']),
                          subtitle: Text(fromUserData['email']),
                          leading: fromUserData['photo'] != null
                              ? Image.network(fromUserData['photo'])
                              : const Icon(Icons.account_circle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  _acceptFriendRequest(request.id, fromUserId);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _declineFriendRequest(request.id);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}