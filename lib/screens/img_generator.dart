import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:translator/translator.dart';

class ImageGen extends StatefulWidget {
  const ImageGen({Key? key}) : super(key: key);

  @override
  _ImageGenState createState() => _ImageGenState();
}

class _ImageGenState extends State<ImageGen> {
  File? _selectedImage;
  String? _generatedText;
  String? _translatedText;
  TextEditingController _textInputController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _generatedText =
            null; // Reset the generated text when a new image is selected
        _translatedText =
            null; // Reset the translated text when a new image is selected
      });
    }
  }

  void _translateAndShowGeminiContent(String outputText) {
    translator.translate(outputText, to: 'si').then((value) {
      String translatedText = value.toString();

      print(translatedText);

      setState(() {
        _translatedText = translatedText;
      });
    });
  }

  Future<void> _generateResponse() async {
    if (_selectedImage == null) {
      return;
    }

    try {
      final apiKey = "AIzaSyC6I358RmUE_IErdz9VnwKZjbJQIukHgsI";
      if (apiKey == null) {
        throw ArgumentError('API_KEY environment variable is not set.');
      }

      final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
      final imageBytes = await _selectedImage!.readAsBytes();

      final prompt = TextPart(_textInputController.text);
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      print('Generated response: ${response.text}');

      setState(() {
        _generatedText = response.text;

        _translateAndShowGeminiContent(_generatedText!);
      });
    } catch (e) {
      print('Error generating response: $e');
    }
  }

  GoogleTranslator translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Description Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildImageInput(),
            SizedBox(height: 20),
            _buildTextInput(),
            SizedBox(height: 20),
            _buildGenerateButton(),
            SizedBox(height: 20),
            _selectedImage != null
                ? DisplaySelectedImage(image: FileImage(_selectedImage!))
                : Text('No image selected'),
            SizedBox(height: 20),
            _generatedText != null
                ? Column(
                    children: [
                      SizedBox(height: 20),
                      _translatedText != null
                          ? Text('Translated Description: $_translatedText')
                          : Container(),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageInput() {
    return ElevatedButton(
      onPressed: _pickImage,
      child: Text('Pick Image'),
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textInputController,
      decoration: InputDecoration(
        labelText: 'Enter Text Prompt',
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: _generateResponse,
      child: Text('Generate Description'),
    );
  }
}

class DisplaySelectedImage extends StatelessWidget {
  final ImageProvider image;

  const DisplaySelectedImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image(
        image: image,
        width: 200.0,
        height: 200.0,
        fit: BoxFit.cover,
      ),
    );
  }
}
