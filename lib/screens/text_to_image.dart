import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TexttoImage extends StatefulWidget {
  const TexttoImage({Key? key}) : super(key: key);

  @override
  State<TexttoImage> createState() => _TexttoImageState();
}

class _TexttoImageState extends State<TexttoImage> {
  Future<Uint8List> generate(String text) async {
    // Implement your logic to generate image data based on the input text
    // For now, I'm returning an empty Uint8List as a placeholder
    return Uint8List(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: brainFusion(),
      ),
    );
  }

  Widget brainFusion() {
    return FutureBuilder<Uint8List>(
      future: generate('Dog'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Image.memory(snapshot.data!);
        } else {
          return Container();
        }
      },
    );
  }
}
