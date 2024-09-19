import 'package:flutter/material.dart';
import 'package:w2eat/Screen/home.dart';
import 'package:w2eat/Screen/Login_Signup/login.dart';
import 'package:w2eat/Services/authentication.dart';
import 'package:w2eat/Screen/Widgets/snackbar.dart';
import '../Widgets/button.dart';
import '../Widgets/text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text
    );

    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: height * 0.05),
                  child: CircleAvatar(
                    radius: width * 0.3, // Tornando o tamanho da imagem responsivo
                    backgroundImage: const AssetImage('images/logo.jpg'),
                  ),
                ),
                SizedBox(height: height * 0.03), // Ajuste o espaçamento vertical
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: TextFieldInput(
                    icon: Icons.person,
                    textEditingController: nameController,
                    hintText: 'Insira o seu Nome',
                    textInputType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.01),
                  child: TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: 'Insira o seu Email',
                    textInputType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.01),
                  child: TextFieldInput(
                    icon: Icons.lock,
                    textEditingController: passwordController,
                    hintText: 'Insira a sua Password',
                    textInputType: TextInputType.text,
                    isPass: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.03),
                  child: MyButtons(onTap: signupUser, text: "Registar"),
                ),
                SizedBox(height: height * 0.05), // Ajuste o espaçamento vertical
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Já possui uma conta?",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Entrar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}