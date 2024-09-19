import 'package:flutter/material.dart';
import 'package:w2eat/Screen/Connections/match_comidas.dart';

class EventPlanner extends StatelessWidget {
  final String title;
  final String description;
  final List<String> members; // IDs dos membros
  final String connectionId; // Adicione o connectionId

  // Função para buscar a URL da foto de um membro
  final Future<String?> Function(String memberId) fetchPhotoUrl;

  const EventPlanner({
    super.key,
    required this.title,
    required this.description,
    required this.members,
    required this.connectionId, // Receba o connectionId
    required this.fetchPhotoUrl, // Função para buscar URL da foto dos membros
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planear Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Membros
            SizedBox(
              height: 60, // Ajuste a altura se necessário
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: members.map((memberId) {
                  return FutureBuilder<String?>(
                    future: fetchPhotoUrl(memberId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Exibe um indicador de carregamento enquanto busca a URL
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        // Exibe um CircleAvatar com um ícone de erro
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      } else {
                        // URL da foto disponível ou imagem padrão
                        final photoUrl = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            backgroundImage: photoUrl != null 
                                ? NetworkImage(photoUrl) 
                                : const AssetImage('images/logo.png') as ImageProvider,
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 0), // Espaço antes dos botões
            // Botões
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navegar para a página FoodSelectionPage com parâmetros
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodSelectionPage(
                              connectionId: connectionId, // Passe o connectionId
                              members: members, // Passe a lista de membros
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Escolher o Prato',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // CircleAvatar para mostrar uma imagem ou apenas para exibir uma imagem padrão
                  const SizedBox(
                    width: 250,
                    height: 250,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      backgroundImage: AssetImage('images/logo.png'), // Imagem padrão ou de exemplo
                      child: null, // Sem texto sobre a imagem
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // Lógica para escolher o restaurante
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Escolher o Restaurante',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
