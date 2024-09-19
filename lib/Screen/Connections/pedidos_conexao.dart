import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionRequestsPage extends StatelessWidget {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference connectionsCollection = FirebaseFirestore.instance.collection('connections');

  ConnectionRequestsPage({super.key});

  Future<List<Map<String, dynamic>>> _getFriendData(List<String> friendIds) async {
    List<Map<String, dynamic>> friendData = [];
    for (String friendId in friendIds) {
      if (friendId != currentUserUid) {
        DocumentSnapshot userSnapshot = await usersCollection.doc(friendId).get();
        if (userSnapshot.exists) {
          friendData.add({'uid': friendId, 'name': userSnapshot['name']});
        }
      }
    }
    return friendData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos de Conexão'),
      ),
      body: StreamBuilder(
        stream: connectionsCollection
            .where('members', arrayContains: currentUserUid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data!.docs.map((connection) {
              List<String> members = List<String>.from(connection['members']);

              // Verifica se o campo 'requester' existe
              var data = connection.data() as Map<String, dynamic>?;
              String? requesterUid = data != null && data.containsKey('requester') ? data['requester'] : null;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _getFriendData(members),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> friendDataSnapshot) {
                  if (!friendDataSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                  List<Map<String, dynamic>> friendData = friendDataSnapshot.data!;
                  List<String> friendNames = friendData.map((data) => data['name'] as String).toList();

                  return ListTile(
                    title: Text('Pedido de Conexão de: ${friendNames.join(', ')}'),
                    trailing: requesterUid != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (requesterUid == currentUserUid) // Se o utilizador atual fez o pedido, só pode cancelar
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    // Cancelar o pedido
                                    connectionsCollection.doc(connection.id).delete();
                                  },
                                ),
                              if (requesterUid != currentUserUid) // Se o utilizador atual recebeu o pedido, pode aceitar ou recusar
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () {
                                        // Aceitar o pedido
                                        connectionsCollection.doc(connection.id).update({'status': 'accepted'});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        // Recusar o pedido
                                        connectionsCollection.doc(connection.id).update({'status': 'rejected'});
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : const Text('Pedido Inválido'), // Tratamento para caso o campo 'requester' não exista
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
