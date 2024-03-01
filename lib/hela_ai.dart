import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

class HelaAI extends StatefulWidget {
  const HelaAI({Key? key}) : super(key: key);

  @override
  State<HelaAI> createState() => _HelaAIState();
}

class _HelaAIState extends State<HelaAI> {
  ChatUser you = ChatUser(id: "1", firstName: "You");
  ChatUser helaAi = ChatUser(id: "2", firstName: "HelaAI");
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  GoogleTranslator translator = GoogleTranslator();

  void translateAndGenerateGeminiContent(String inputText) {
    translator.translate(inputText, to: 'en').then((value) {
      setState(() {
        String translatedText = value.toString();
        print(translatedText);
        generateGeminiContent(translatedText);
      });
    });
  }

  Future<void> generateGeminiContent(String translatedText) async {
    typing.add(helaAi);
    final ourUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyC6I358RmUE_IErdz9VnwKZjbJQIukHgsI";
    final header = {'Content-Type': 'application/json'};
    var data = {"contents": [{"parts": [{"text": translatedText}]}]};

    try {
      final response =
          await http.post(Uri.parse(ourUrl), headers: header, body: jsonEncode(data));

      if (response.statusCode == 200) {
        handleGeminiResponse(response.body);
      } else {
        print("Error Occurred");
      }
    } catch (e) {
      print("Error Occurred: $e");
    }
    typing.remove(helaAi);
  }

   void translateAndShowGeminiContent(String outputText) {
  translator.translate(outputText, to: 'si').then((value) {
    setState(() {
      String translatedText = value.toString();
      print(translatedText);

      // Display the translated content
      ChatMessage m1 = ChatMessage(
        user: helaAi,
        createdAt: DateTime.now(),
        text: translatedText,
      );

      allMessages.insert(0, m1);

      setState(() {});
    });
  });
}

void handleGeminiResponse(String responseBody) {
  try {
    var decodedValue = jsonDecode(responseBody);
    var result = decodedValue["candidates"][0]["content"]["parts"][0]["text"];
    print(result);

    // Translate and show the content
    translateAndShowGeminiContent(result);
  } catch (e) {
    print("Error handling Gemini response: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hela AI'),
      ),
      body: DashChat(
        messageOptions: MessageOptions(showTime: true),
        currentUser: you,
        typingUsers: typing,
        onSend: (ChatMessage m) {
          // Handle message sending logic here
          allMessages.insert(0, m); // Add the message to the chat instantly
          setState(() {});
          translateAndGenerateGeminiContent(m.text);
        },
        messages: allMessages,
      ),
    );
  }
}
