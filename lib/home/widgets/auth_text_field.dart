import 'package:flutter/material.dart';

import '../../constants.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final TextInputType _inputType;
  final bool _obscureText;
  // final Function(String)? onChanged;
  final TextEditingController controller;

  const AuthTextField(
      {required this.hintText,
      required this.controller,
      inputType,
      obscureText})
      : _inputType = inputType ?? TextInputType.text,
        _obscureText = obscureText ?? false,
        super();

  factory AuthTextField.email(
      {required String hintText, required TextEditingController controller}) {
    return AuthTextField(
        hintText: hintText,
        inputType: TextInputType.emailAddress,
        obscureText: false,
        controller: controller);
  }

  factory AuthTextField.password(
      {required String hintText, required TextEditingController controller}) {
    return AuthTextField(
        hintText: hintText,
        inputType: TextInputType.text,
        obscureText: true,
        controller: controller);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: _inputType,
      textAlign: TextAlign.center,
      obscureText: _obscureText,
      decoration: AppTheme.textFieldDecoration.copyWith(hintText: hintText),
      controller: controller,
    );
  }
}
