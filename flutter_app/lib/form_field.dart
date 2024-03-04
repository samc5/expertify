import 'package:flutter/material.dart';

class LogFormField extends StatelessWidget {
  const LogFormField(
      {super.key,
      required this.textValue,
      required this.formLabel,
      required this.password});

  final TextEditingController textValue;
  final String formLabel;
  final bool password;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: password ? true : false,
      controller: textValue,
      decoration: InputDecoration(
        hintText: formLabel,
        border: OutlineInputBorder(
          // Solid border
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        focusedBorder: OutlineInputBorder(
          // Custom border when focused
          borderSide: BorderSide(
              color: Color.fromARGB(255, 7, 64, 164),
              width: 2.0), // Border color and width
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        enabledBorder: OutlineInputBorder(
          // Custom border when not focused
          borderSide: BorderSide(
              color: Colors.black, width: 2.0), // Border color and width
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
      ),
    );
  }
}
