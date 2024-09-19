import 'package:flutter/material.dart';

class AddFoodPage extends StatelessWidget {
  const AddFoodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novos Pratos'),
      ),
      body: const Center(
        child: Text('Página de Adicionar Novos Pratos'),
      ),
    );
  }
}
