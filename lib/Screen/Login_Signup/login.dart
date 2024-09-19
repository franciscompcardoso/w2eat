import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:w2eat/Screen/home.dart';
import 'package:w2eat/Screen/Login_Signup/signup.dart';
import 'package:w2eat/Services/authentication.dart';
import 'package:w2eat/Screen/Widgets/button.dart';
import 'package:w2eat/Screen/Widgets/snackbar.dart';
import 'package:w2eat/Screen/Widgets/text_field.dart';
import 'package:w2eat/Screen/Login_Signup/forgot_password.dart';
import '../../Services/google_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // email and passowrd auth part
  void loginUser() async {
  setState(() {
    isLoading = true;
  });
  String res = await AuthServices().loginUser(
    email: emailController.text, 
    password: passwordController.text
  );

  if (res == "success") {
    setState(() {
      isLoading = false;
    });
    if (kDebugMode) {
      print('Login successful, redirecting to home page...');
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  } else {
    setState(() {
      isLoading = false;
    });
    // ignore: use_build_context_synchronously
    showSnackBar(context, res);
  }
}

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 95, 20, 14),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: height * 0.02),
                child: CircleAvatar(
                  radius: width * 0.3, // Tornando o tamanho da imagem responsivo
                  backgroundImage: const AssetImage('images/logo.jpg'),
                ),
              ),
              SizedBox(height: height * 0.03), // Ajuste o espaçamento vertical
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: TextFieldInput(
                  textEditingController: emailController,
                  hintText: "Introduza o seu email",
                  icon: Icons.email,
                  textInputType: TextInputType.text,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.01),
                child: TextFieldInput(
                  textEditingController: passwordController,
                  hintText: "Introduza a sua password",
                  icon: Icons.lock,
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: ForgotPassword(),
              ),
              MyButtons(onTap: loginUser, text: "Entrar"),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.05),
                child: SizedBox(
                  width: width * 0.8, // Defina a largura como uma porcentagem da tela
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: EdgeInsets.symmetric(vertical: height * 0.015), // Ajuste o preenchimento vertical conforme necessário
                    ),
                    onPressed: () async {
                      await FirebaseServices().signInWithGoogle();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centraliza o conteúdo
                      children: [
                        Image.network(
                          "https://ouch-cdn2.icons8.com/VGHyfDgzIiyEwg3RIll1nYupfj653vnEPRLr0AeoJ8g/rs:fit:456:456/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvODg2/LzRjNzU2YThjLTQx/MjgtNGZlZS04MDNl/LTAwMTM0YzEwOTMy/Ny5wbmc.png",
                          height: height * 0.03,
                        ),
                        SizedBox(width: width * 0.02),
                        const Text(
                          "Continuar com conta Google",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height / 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Não possui Conta?",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      " Registar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
