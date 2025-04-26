import 'package:flutter/material.dart';

// Botones para la pantalla de inicio
class ProviderLoginBtn extends StatelessWidget {
  final String text;
  final Image img;
  final VoidCallback onPressed;

  const ProviderLoginBtn({
    super.key,
    required this.text,
    required this.img,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        maximumSize: Size(200, 50),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: img.image, height: 24, width: 24),
            SizedBox(width: 5),
            Text(text, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
