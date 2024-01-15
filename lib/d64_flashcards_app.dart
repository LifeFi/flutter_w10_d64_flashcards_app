import 'package:flutter/material.dart';

class D64FlashcardsApp extends StatefulWidget {
  const D64FlashcardsApp({super.key});

  @override
  State<D64FlashcardsApp> createState() => _D64FlashcardsAppState();
}

class _D64FlashcardsAppState extends State<D64FlashcardsApp> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Falshcards App"),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 10,
              color: Colors.red.shade100,
              child: SizedBox(
                width: size.width * 0.8,
                height: size.height * 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
