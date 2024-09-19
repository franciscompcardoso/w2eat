import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:w2eat/Screen/Connections/conexoes_aceites.dart';
import 'package:w2eat/Screen/Friends/lista_amigos.dart';
import 'package:w2eat/Screen/Food/favorite_food.dart';
import 'package:w2eat/Screen/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User user;
  int _selectedIndex = 0; // Controla o índice da página selecionada

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
  }

  // Função para atualizar a página exibida
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para retornar o widget da página central de acordo com o índice
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const FavoriteFood();
      case 1:
        return AcceptedConnectionsPage();
      case 2:
        return FriendsListPage(currentUserId: user.uid);
      case 3:
        return const Profile();
      default:
        return const FavoriteFood();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ligações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Amigos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

