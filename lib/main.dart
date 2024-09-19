import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:w2eat/Screen/Login_Signup/login.dart';
import 'package:w2eat/Screen/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color.fromARGB(255, 251, 223, 223),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 254, 178, 178),  
          foregroundColor: Colors.black,
          toolbarHeight: 70,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto', // Define a fonte da AppBar aqui
            fontSize: 20, // Ajuste o tamanho conforme necessário
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 95, 20, 14),
        ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 254, 178, 178), // Cor de fundo da BottomNavigationBar
          selectedItemColor: const Color.fromARGB(255, 95, 20, 14), // Cor dos itens selecionados
          unselectedItemColor: Colors.grey[600], // Cor dos itens não selecionados
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.black, // Cor da barra de status
          statusBarIconBrightness: Brightness.light, // Cor dos ícones na barra de status
        ),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData) {
              return const SafeArea(child: HomeScreen());
            } else {
              return const SafeArea(child: LoginScreen());
            }
          },
        ),
      ),
    );
  }
}
