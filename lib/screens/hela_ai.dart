import 'dart:convert';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hela_ai/navigations/side_nav.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;

class HelaAI extends StatefulWidget {
  const HelaAI({Key? key}) : super(key: key);

  @override
  State<HelaAI> createState() => _HelaAIState();
}

class _HelaAIState extends State<HelaAI> {
  ChatUser you = ChatUser(id: "1", firstName: "You");
  ChatUser helaAi = ChatUser(id: "2", firstName: "හෙළ GPT");
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
    var data = {
      "contents": [
        {
          "parts": [
            {"text": translatedText}
          ]
        }
      ]
    };

    try {
      final response = await http.post(Uri.parse(ourUrl),
          headers: header, body: jsonEncode(data));

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

      // Split text at ** and store segments in a list
      List<String> textSegments = result.split("**");

      // Reconstruct the text with bold formatting using RichText widget
      List<TextSpan> textSpans = [];
      for (int i = 0; i < textSegments.length; i++) {
        if (i % 2 == 1) {
          // If it's an odd-indexed segment (bold part)
          textSpans.add(TextSpan(
            text: textSegments[i],
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ));
        } else {
          textSpans.add(TextSpan(
              text: textSegments[i],
              style: TextStyle(fontSize: 16, color: Colors.white)));
          print("error bold");
        }
      }

      // Create a RichText widget to display the formatted text
      RichText richText = RichText(
        text: TextSpan(children: textSpans),
      );

      // Convert RichText to a plain String for the function call
      String plainText = richText.text.toPlainText();

      translateAndShowGeminiContent(plainText);
    } catch (e) {
      print("Error handling Gemini response: $e");
    }
  }

  Future<void> saveChatsToFile() async {
    try {
      // Get the directory for storing files
      String dir = (await getApplicationDocumentsDirectory()).path;
      if (dir == null) {
        // Handle the case where getting the directory fails
        print("Error: Couldn't get directory for saving chats");
        // Display an error message to the user here
        return;
      }
      try {
        // Get the directory for storing files
        Directory dir = await getApplicationDocumentsDirectory();
        String filePath = '${dir.path}/හෙළGPT_chat.txt';

        // Open the file
        File file = File(filePath);
        IOSink sink = file.openWrite();

        // Write each message to the file
        for (ChatMessage message in allMessages) {
          if (message.text.isNotEmpty) {
            String messageText = '${message.user.firstName}: ${message.text}\n';
            sink.write(messageText);
          }
        }

        // Close the file
        await sink.close();

        // Show a snackbar or toast indicating the file is saved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat history saved to $filePath')),
        );

        // Share the file
        Share.shareFiles([filePath]);
      } catch (e) {
        print('Error saving chat history: $e');
      } catch (e) {
        print('Error saving chat history: $e');
      }

      // ... rest of the saveChatsToFile() code
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await saveChatsToFile();
                  // if (dir!= null) {
                  //   Share.shareFiles(['$dir/හෙළGPT_chat.txt']);

                  // }else{
                  //   print("Error: Directory not found");
                  // }
                },
                icon: Icon(Icons.share)),
          ],
          backgroundColor: Color.fromARGB(255, 48, 48, 48),
          title: const Text(
            'හෙළ GPT',
            style: TextStyle(
                fontSize: 15, color: Color.fromARGB(255, 255, 255, 255)),
          ),
          // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search))],

          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
        ),
        drawer: SideNav(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/images/back-light.png'
                    : 'assets/images/back-dark.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: DashChat(
            messageOptions: MessageOptions(showTime: true),
            currentUser: you,
            typingUsers: typing,
            onSend: (ChatMessage m) {
              // Handle message sending logic here
              allMessages.insert(0, m); // Add the message to the chat instantly
              setState(() {});
              checkInputs(m.text);
            },
            messages: allMessages,
          ),
        ),
      ),
    ]);
  }

  List<String> guesses = [
    "oya kwd",
    "ඔයා",
    "ඔයා කවුද?",
    "ඔයා කවුද",
    "ඔයා කවුද හැදුවෙ",
    "oya kwd haduwe?",
    "oya kwd haduwe",
    "ඔයා කවුද ඇදුවෙ?"
  ];

  @override
  void checkInputs(String inputs) {
    if (guesses.contains(inputs)) {
      typing.add(helaAi);

      Future.delayed(Duration(seconds: 2), () {
        translateAndShowGeminiContent(
            "මම හෙළ GPT, LankaTech Innovations විසින් නිර්මාණය කරන ලද භාෂා ආකෘතියකි. ඔබට අවශ්‍ය විය හැකි ඕනෑම ප්‍රශ්නයක් හෝ තොරතුරු සමඟ ඔබට සහාය වීමට මම මෙහි සිටිමි. කොහොමද මම අද ඔබට උපකාර කළ හැක්කේ කෙසේද?");
        typing.remove(helaAi);
        setState(
            () {}); // Make sure to call setState to trigger a rebuild if needed
      });
    } else {
      translateAndGenerateGeminiContent(inputs);
      typing.remove(helaAi);
    }
  }
}
