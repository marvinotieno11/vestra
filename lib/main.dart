 import 'package:flutter/material.dart';

void main() {
  runApp(const VestraApp());
}

class VestraApp extends StatelessWidget {
  const VestraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vestra',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        fontFamily: 'Arial',
      ),
      home: const VestraHome(),
    );
  }
}

class VestraHome extends StatelessWidget {
  const VestraHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'VESTRA',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Your AI fashion companion',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: () {},
                child: const Text('Begin your style journey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}