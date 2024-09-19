import 'package:flutter/material.dart';
import 'package:w2eat/Screen/Food/adicionar_comida.dart';
import 'package:w2eat/Screen/Food/favorite_list.dart';
import 'favorite_food.dart'; // Importe a página de Comida Favorita

class FoodLayout extends StatelessWidget {
  const FoodLayout({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comida Favorita'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 1,
        childAspectRatio: 3,
        children: <Widget>[
          CardButton(
            title: 'Comida Favorita',
            color: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteFood()),
              );
            },
          ),
          CardButton(
            title: 'Lista Favorita de Pratos',
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteList()),
              );
            },
          ),
          CardButton(
            title: 'Adicionar Novos Pratos',
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddFoodPage()),
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