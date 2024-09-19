import 'package:flutter/material.dart';
import 'package:w2eat/Screen/Connections/conexoes_aceites.dart';
import 'package:w2eat/Screen/Connections/criar_conexao.dart';
import 'package:w2eat/Screen/Connections/pedidos_conexao.dart';

class ConnectionsLayout extends StatelessWidget {
  const ConnectionsLayout({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ligações'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 1,
        childAspectRatio: 3,
        children: <Widget>[
          CardButton(
            title: 'Criar Ligação',
            color: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateConnectionPage()),
              );
            },
          ),
          CardButton(
            title: 'Pedidos de Ligação',
            color: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectionRequestsPage()),
              );
            },
          ),
          CardButton(
            title: 'Ligações',
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AcceptedConnectionsPage()),
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