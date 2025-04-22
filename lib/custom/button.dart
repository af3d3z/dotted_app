import 'package:flutter/material.dart';

// Botones para la pantalla de inicio
class DottedMainBtn extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const DottedMainBtn({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: Size(200, 40),
      ),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}
