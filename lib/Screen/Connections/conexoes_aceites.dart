import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:w2eat/Screen/Connections/criar_conexao.dart';
import 'package:w2eat/Screen/Connections/planear_evento.dart';

class AcceptedConnectionsPage extends StatelessWidget {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference connectionsCollection = FirebaseFirestore.instance.collection('connections');

  AcceptedConnectionsPage({super.key});

  Future<Map<String, dynamic>> _getConnectionDetails(String connectionId) async {
    DocumentSnapshot connectionSnapshot = await connectionsCollection.doc(connectionId).get();
    if (connectionSnapshot.exists) {
      Map<String, dynamic> connectionData = connectionSnapshot.data() as Map<String, dynamic>;
      List<String> members = List<String>.from(connectionData['members']);
      String title = connectionData['title'] ?? 'Sem Título';
      String description = connectionData['description'] ?? 'Sem Descrição';
      String requesterUid = connectionData['requester'] ?? '';

      // Get friend names
      List<String> friendNames = [];
      for (String friendId in members) {
        if (friendId != currentUserUid) {
          DocumentSnapshot userSnapshot = await usersCollection.doc(friendId).get();
          if (userSnapshot.exists) {
            friendNames.add(userSnapshot['name'] ?? 'Desconhecido');
          }
        }
      }

      // Determine if current user is the creator
      bool isCreator = requesterUid == currentUserUid;

      // Determine the status of the connection
      String status = connectionData['status'] ?? 'unknown';

      // Get the acceptance status of each member
      Map<String, dynamic> acceptances = connectionData['acceptances'] ?? {};

      members
          .where((member) => member != currentUserUid)
          .every((member) => acceptances[member] == true);

      return {
        'title': title,
        'description': description,
        'names': friendNames,
        'isCreator': isCreator,
        'status': status,
        'canNavigate': status == 'accepted' // Navigate if the status is 'accepted'
      };
    }
    return {};
  }

  Future<void> _acceptConnection(BuildContext context, String connectionId) async {
    try {
      await connectionsCollection.doc(connectionId).update({
        'acceptances.$currentUserUid': true,
        'status': 'accepted', // Change status to accepted if needed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexão aceita.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar a conexão: $error')),
      );
    }
  }

  Future<void> _rejectConnection(BuildContext context, String connectionId) async {
    try {
      await connectionsCollection.doc(connectionId).delete(); // Remove the document
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexão recusada.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao recusar a conexão: $error')),
      );
    }
  }

  Future<void> _removeConnection(BuildContext context, String connectionId) async {
    try {
      await connectionsCollection.doc(connectionId).delete(); // Remove the document
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conexão removida.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover a conexão: $error')),
      );
    }
  }

  Future<String?> fetchPhotoUrl(String memberId) async {
    try {
      DocumentSnapshot userSnapshot = await usersCollection.doc(memberId).get();
      if (userSnapshot.exists) {
        return userSnapshot['photoURL'] as String?;
      }
    } catch (e) {
      // Handle any errors here
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexões Aceitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateConnectionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: connectionsCollection
            .where('members', arrayContains: currentUserUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((connection) {
              String connectionId = connection.id;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getConnectionDetails(connectionId),
                builder: (context, AsyncSnapshot<Map<String, dynamic>> connectionDetailsSnapshot) {
                  if (!connectionDetailsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var connectionDetails = connectionDetailsSnapshot.data!;
                  String title = connectionDetails['title'] ?? 'Sem Título';
                  String description = connectionDetails['description'] ?? 'Sem Descrição';
                  List<String> friendNames = List<String>.from(connectionDetails['names'] ?? []);
                  bool isCreator = connectionDetails['isCreator'] ?? false;
                  String status = connectionDetails['status'] ?? 'unknown';
                  bool canNavigate = connectionDetails['canNavigate'] ?? false;

                  return GestureDetector(
                    onTap: () {
                      if (canNavigate) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventPlanner(
                              title: title,
                              description: description,
                              members: List<String>.from(connection['members']),
                              connectionId: connectionId,
                              fetchPhotoUrl: fetchPhotoUrl, // Passa a função fetchPhotoUrl
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(description),
                            isThreeLine: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Conexão com: ${friendNames.join(', ')}'),
                          ),
                          ButtonBar(
                            children: [
                              if (isCreator)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeConnection(context, connectionId),
                                ),
                              if (!isCreator && status == 'pending')
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _acceptConnection(context, connectionId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _rejectConnection(context, connectionId),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
