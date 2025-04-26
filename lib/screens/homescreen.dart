import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void dispose() {
    super.dispose(); // Always call super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            children: const [
              Text(
                "Homescreen",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
