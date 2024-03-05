import 'dart:convert';
import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hela_ai/coatchmark_des/coatch_mark_des.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/navigations/side_nav.dart';
import 'package:hela_ai/themprovider/theamdata.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:intl/intl.dart';

bool isTyping = false;

ChatUser you = ChatUser(
    id: "1", firstName: "You", profileImage: 'assets/images/lion_avetar.png');
ChatUser helaAi =
    ChatUser(profileImage: 'assets/images/lion_avetar.png', id: '2');

class HelaAI extends StatefulWidget {
  final UserModal user;

  const HelaAI({Key? key, required this.user}) : super(key: key);

  @override
  State<HelaAI> createState() => _HelaAIState();
}

class _HelaAIState extends State<HelaAI> {
  List<TargetFocus> targets = [];

  TextEditingController messageController = TextEditingController();

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  GoogleTranslator translator = GoogleTranslator();

  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      showTutorial();
    });
  }

  // Tutorial

  void showTutorial() {
    _initTargets();
    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      targets: targets,
    )..show(context: context);
  }

  // Globle Keys

  GlobalKey sharekey = GlobalKey();
  GlobalKey menukey = GlobalKey();
  GlobalKey navkey = GlobalKey();

  void _initTargets() {
    targets = [
      TargetFocus(identify: "menu-key", keyTarget: menukey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachMarkDes(
                text: "Navigate through the menu",
                onSkip: () {
                  controller.skip();
                },
                onNext: () {
                  controller.next();
                },
              );
            })
      ]),
      TargetFocus(identify: "share-key", keyTarget: sharekey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachMarkDes(
                text: "Share Your Chat with others",
                onSkip: () {
                  controller.skip();
                },
                onNext: () {
                  controller.next();
                },
              );
            })
      ]),
      // Add more TargetFocus objects if needed
    ];
  }

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
    isTyping = true;
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
    isTyping = false;
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              key: sharekey,
              onPressed: () async {
                await saveChatsToFile();
              },
              icon: Icon(Icons.share)),
        ],
        backgroundColor: Color.fromARGB(255, 48, 48, 48),
        title: const Text(
          'හෙළ GPT',
          style: TextStyle(
              fontSize: 15, color: Color.fromARGB(255, 255, 255, 255)),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              key: menukey,
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: SideNav(
        user: widget.user,
      ),
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: allMessages.length,
                itemBuilder: (context, index) {
                  final message = allMessages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            isTyping ? TypingIndicator() : SizedBox(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius as needed
                        border:
                            Border.all(color: Colors.grey), // Set border color
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 48, // Set the desired height for the button
                    child: Visibility(
                      visible: messageController.text.isNotEmpty,
                      child: ElevatedButton(
                        onPressed: () {
                          final messageText = messageController.text.trim();
                          if (messageText.isNotEmpty) {
                            final message = ChatMessage(
                              user: you,
                              createdAt: DateTime.now(),
                              text: messageText,
                            );
                            allMessages.insert(0, message);

                            setState(() {});
                            checkInputs(messageText);
                            messageController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(), // Make the button circular
                          elevation:
                              0.0, // Set elevation to 0.0 to remove the background shadow
                          shadowColor: Colors
                              .transparent, // Set shadowColor to transparent
                        ),
                        child: Icon(Icons.send),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = message.user == you;
    final ThemeData theme = isCurrentUser ? lightTheme : darkTheme;

    return ListTile(
      leading: isCurrentUser
          ? null // No avatar for current user on the left
          : CircleAvatar(
              // Add AI avatar on the left
              backgroundImage: AssetImage('assets/images/lion_avetar.png')
              ,
              backgroundColor: Colors.transparent,
            ),
      trailing: isCurrentUser
          ? CircleAvatar(
              // Add user avatar on the right
              backgroundImage: AssetImage('assets/images/user_avetar.png'),
            )
          : null, // No avatar for AI on the right
      title: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isCurrentUser
                  ? theme.primaryColor
                  : theme.scaffoldBackgroundColor,
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isCurrentUser
                    ? Colors.white
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          SizedBox(height: 4), // Add spacing between message and timestamp
          Text(
            DateFormat.Hm().format(message.createdAt), // Format time as HH:mm
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Lottie.network(
            "https://lottie.host/7b1625cc-828e-44b7-b507-920b4581e345/okYRr6A8oe.json",
            width: 35, // Set your desired width
            height: 35, // Set your desired height
          )
        ],
      ),
    );
  }
}
