import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences, required InputDecoration decoration, // Configuração padrão
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}