import 'package:flutter/material.dart';

class CommonFoodsPage extends StatelessWidget {
  final List<String> commonFoods;

  const CommonFoodsPage({super.key, required this.commonFoods});

  @override
  Widget build(BuildContext context) {
    // Exibe o diálogo se não houver comidas em comum
    if (commonFoods.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Aguarde'),
              content: const Text('Nenhuma comida foi selecionada por todos os membros.'),
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
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comidas em Comum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: commonFoods.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  commonFoods[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
