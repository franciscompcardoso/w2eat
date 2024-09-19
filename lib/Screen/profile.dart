import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:w2eat/Classes/User.dart';
import 'package:w2eat/Screen/Login_Signup/login.dart';
import 'package:w2eat/Screen/Widgets/button.dart';
import 'package:w2eat/Services/authentication.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      UserModel? fetchedUser = await UserService().getUser(user!.uid);
      setState(() {
        userModel = fetchedUser;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (userModel?.photoURL != null && userModel!.photoURL!.isNotEmpty)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userModel!.photoURL!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person),
                ),
              const SizedBox(height: 16),
              Text(
                userModel?.name ?? 'No name provided',
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                userModel?.email ?? 'No email provided',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
               MyButtons(
                onTap: () async {
                  try {
                    await AuthServices().signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  } catch (e) {
                    // Mostrar uma mensagem de erro caso o logout falhe
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao terminar sessão: $e'),
                      ),
                    );
                  }
                },
                text: "Terminar Sessão",
              ),
            ],
          ),
        ),
      ),
    );
  }
}