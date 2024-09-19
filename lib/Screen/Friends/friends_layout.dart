import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:w2eat/Screen/Friends/lista_amigos.dart';
import 'package:w2eat/Screen/Friends/pedidos_amizade.dart';

class FriendsLayout extends StatefulWidget {
  const FriendsLayout({super.key, required String currentUserId});

  @override
  State<FriendsLayout> createState() => FriendsLayoutState();
}

class FriendsLayoutState extends State<FriendsLayout> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligações', style: TextStyle(color: Colors.white)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 1,
        childAspectRatio: 3,
        children: <Widget>[
          CardButton(
            title: 'Pedidos de Amizade',
            color: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestsPage(currentUserId: user.uid,)),
              );
            },
          ),
          CardButton(
            title: 'Lista de Amigos',
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendsListPage(currentUserId: user.uid,)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CardButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const CardButton({
    Key? key,
    required this.title,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}