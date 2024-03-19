import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hela_ai/Coines/coin.dart';
import 'package:hela_ai/Coines/coine_update.dart';
import 'package:hela_ai/coatchmark_des/coatch_mark_des.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/navigations/side_nav.dart';
import 'package:hela_ai/setting_maneger/settign_maneger.dart';
import 'package:hela_ai/themprovider/theamdata.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Add this line for the platform channel
import 'package:path/path.dart' as path;

bool isTyping = false;
bool isSpeaking = false;


 


ChatUser you = ChatUser(
    id: "1", firstName: "You", profileImage: 'assets/images/lion_avetar.png');
ChatUser helaAi =
    ChatUser(profileImage: 'assets/images/lion_avetar.png', id: '2');

class HelaAI extends StatefulWidget {
  final UserModal user;

  const HelaAI({Key? key, required this.user, required String img_url})
      : super(key: key);

  @override
  State<HelaAI> createState() => _HelaAIState();
}

class _HelaAIState extends State<HelaAI> {
  List<TargetFocus> targets = [];

  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordSpoken = ' ';
  double _confidenceLevel = 0;

  TextEditingController messageController = TextEditingController();

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  GoogleTranslator translator = GoogleTranslator();

  bool isFirstTime = true;

  void initState() {
    super.initState();
    checkAutoVoiceStatus();
    Future.delayed(Duration(seconds: 1), () {
      if (isFirstTime) {
        checkTutorialStatus();
        isFirstTime =
            false; // Update the variable to indicate that the tutorial has been shown
      }
      initSpeech();
    });
  }

  SettingsManager _settingsManager = SettingsManager();
  late bool _autoVoiceStatus;

  Future<void> _loadAutoVoiceStatus() async {
    await _settingsManager.loadSettings();
    setState(() {
      _autoVoiceStatus = _settingsManager.enableAutoVoice;
    });
  }

  // image generator

  void checkAutoVoiceStatus() async {
    await _loadAutoVoiceStatus();
    print('Auto Voice is ${_autoVoiceStatus ? 'enabled' : 'disabled'}');
  }

// check first time user tutorial show

  Future<void> checkTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        Future.delayed(Duration(seconds: 1), () {
          showTutorial();
          print("Firstime user");
          prefs.setBool(
              'isFirstTime', false); // Update the variable in SharedPreferences
          initSpeech();
        });
      } else {
        // Tutorial already shown, proceed directly to initSpeech()
        Future.delayed(Duration(seconds: 1), () {
          initSpeech();
          print("2nd time user");
        });
      }
    });
  }

  // Initialize speech functionality asynchronously.
 bool _isInitializing = false; // Add this variable to track initialization state

void initSpeech() async {
  if (!_isInitializing) { // Check if initialization is already in progress
    _isInitializing = true; // Set initialization flag to true
    _speechEnabled = await _speechToText.initialize();
    _isInitializing = false; // Reset initialization flag
    setState(() {});
  }
}


  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'si_LK', // Set Sinhala locale
    );

    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });

    if (result.finalResult) {
      // If it's the final result, send the recognized text to the chat
      sendMessage(_wordSpoken);
    }
  }

  void sendMessage(String text) {
    final message = ChatMessage(
      user: you,
      createdAt: DateTime.now(),
      text: text,
    );
    allMessages.insert(0, message);
    setState(() {});
    checkInputs(text);
    messageController.clear();
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // Tutorial
  // Function to display a tutorial using TutorialCoachMark
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
  GlobalKey chatkey = GlobalKey();
  GlobalKey voice = GlobalKey();

  // Initialize the targets for the CoachMark library, including menu and share targets.
  void _initTargets() {
    targets = [
      TargetFocus(
          shape: ShapeLightFocus.RRect,
          identify: "chat-key",
          keyTarget: chatkey,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                builder: (context, controller) {
                  return CoachMarkDes(
                    text: "මෙතනින් chat කරල ප්‍රශ්න අහන්න",
                    onSkip: () {
                      controller.skip();
                    },
                    onNext: () {
                      controller.next();
                    },
                  );
                })
          ]),
      TargetFocus(identify: "voice-key", keyTarget: voice, contents: [
        TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return CoachMarkDes(
                text: "හෝ මයික් එක භාවිතයෙන් හෙළ GPT සමග කතාකරල ප්‍රශ්න අහන්න",
                onSkip: () {
                  controller.skip();
                },
                onNext: () {
                  controller.next();
                },
              );
            })
      ]),
      TargetFocus(identify: "menu-key", keyTarget: menukey, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachMarkDes(
                text: "Menu එක මෙතනින් භාවිතා කරන්න පුලුවන්",
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
                text: "ඔබ ඇසූ ප්‍රශ්න සහ පිලිතුරු යහලුවන් සමඟ බෙදාගන්න මෙතනින්",
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



  //Gemini Pro Version
  Future<void> generateGeminiProContent(String translatedText2) async {
    final generationConfig = {
      "temperature":
          1, // Controls randomness (0.0 = deterministic, 1.0 = very random)
      "topK": 1, // Restricts generation to top k most likely words at each step
      "topP":
          1.0, // Restricts generation to words with top cumulative probability
      "maxOutputTokens": 2048, // Maximum number of tokens to be generated
      // Add other configuration properties as needed (refer to Gemini API documentation)
    };

    isTyping = true;
    final apiKey = dotenv.env['API_KEY'] ?? "";
    final ourUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro-001:generateContent?key=$apiKey";
    final header = {'Content-Type': 'application/json'};
    final data = {
      "contents": [
        {
          "parts": [
            {"text": translatedText2}
          ]
        }
      ],
      "generationConfig": generationConfig,
    };

    try {
      final response = await http.post(Uri.parse(ourUrl),
          headers: header, body: jsonEncode(data));

      if (response.statusCode == 200) {
        handleGeminiResponse(response.body);
      } else {
        print("Error Occurred");
        translateAndShowGeminiContent(
            "යම් කිසි වැරැද්දක් ඇත කරුනාකර නැවත උතසාහ කරන්න");
        isTyping = false;
      }
    } catch (e) {
      print("Error Occurred: $e");
      isTyping = false;
      translateAndShowGeminiContent(
          "යම් කිසි වැරැද්දක් ඇත කරුනාකර නැවත උතසාහ කරන්න");
    }
    typing.remove(helaAi);

    isTyping = false;
  }


  //Gemini Normle Version

  Future<void> generateGeminiContent(String translatedText) async {
       isTyping = true;
  try {
    
    int coins = await getCurrentCoins();
    
    if (coins < 10) {
      translateAndShowGeminiContent("You don't have enough coins.");
      isTyping = false;
    } else {
      final generationConfig = {
        "temperature": 1,
        "topK": 1,
        "topP": 1.0,
        "maxOutputTokens": 2048,
        // Add other configuration properties as needed
      };

      isTyping = true;
      final apiKey = dotenv.env['API_KEY'] ?? "";
      final ourUrl =
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey";
      final header = {'Content-Type': 'application/json'};
      final data = {
        "contents": [
          {
            "parts": [
              {"text": translatedText}
            ]
          }
        ],
        "generationConfig": generationConfig,
      };

      final response = await http.post(Uri.parse(ourUrl),
          headers: header, body: jsonEncode(data));

      if (response.statusCode == 200) {
        handleGeminiResponse(response.body);
        await CoinsUpdate.updateCoins(10);
        isTyping = false;
      } else {
        print("Error: ${response.statusCode}");
        translateAndShowGeminiContent(
            "කරුනාකර ඔබගේ අන්තර්ජාල සබඳතාව පරීක්ශාකර නැවත උත්සාහ කරන්න.");
      }
    }
  } catch (e) {
    print("Error Occurred: $e");
    translateAndShowGeminiContent(
        "කරුනාකර ඔබගේ අන්තර්ජාල සබඳතාව පරීක්ශාකර නැවත උත්සාහ කරන්න.");
  } finally {
    isTyping = false;
    typing.remove(helaAi);
  }
}


// Future<void> speakSinhala(String text, SettingsManager settingsManager) async {
//   // ... (existing code)

//   // Perform asynchronous operations outside of setState
//   await flutterTts.setLanguage("si-LK");
//   await flutterTts.setPitch(1.0);
//   await flutterTts.setSpeechRate(0.5);

//   // Check auto voice status and trigger speaking if enabled
//   if (settingsManager.enableAutoVoice) {
//     await flutterTts.speak(text);
//     print("Manager: $settingsManager");
//   } else {
//     print("Auto Voice Disabled");
//   }
// }
// Asynchronous function to speak Sinhala text if text-to-speech is enabled in the settings.
  Future<void> speakSinhala(
      String text, SettingsManager settingsManager) async {
    // Check if text-to-speech is enabled in the settings
    if (settingsManager.enableAutoVoice) {
      await flutterTts.setLanguage("si-LK");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(text);

      setState(() {});
    }
  }

// Translates the given outputText to Sinhala and displays the translated content as a ChatMessage. It also updates the UI by inserting the ChatMessage at the beginning of the list and checks the auto voice setting to speak the translated text if enabled.
  void translateAndShowGeminiContent(String outputText) {
    // Using a translator to translate the outputText to Sinhala ('si')
    translator.translate(outputText, to: 'si').then((value) async {
      // Retrieve the translated text
      String translatedText = value.toString();

      // Print the translated text to the console
      print(translatedText);
  

      // Display the translated content as a ChatMessage
      ChatMessage m1 = ChatMessage(
        user: helaAi,
        createdAt: DateTime.now(),
        text: translatedText,
      );

      // Update the UI by inserting the ChatMessage at the beginning of the list
      setState(() {
        allMessages.insert(0, m1);
         isTyping = false;

        // Check the auto voice setting
        if (_settingsManager.enableAutoVoice) {
          // If auto voice is enabled, speak the translated text
          speakSinhala(translatedText, _settingsManager);
        }
      });
    });
  }

  // A function that handles the Gemini response by decoding the JSON, extracting specific parts, reconstructing the text with bold formatting using RichText widget, creating a RichText widget to display the formatted text, converting the RichText to a plain String, and finally calling the translateAndShowGeminiContent function with the plain text. It catches any errors that occur during the process and prints an error message.

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
            icon: Icon(Icons.share),
          ),
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
                  return ChatBubble(
                    message: message,
                    img_url: widget.user.img_url,
                  );
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
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                key: chatkey,
                                controller: messageController,
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle:TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                onChanged: (text) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            key: voice,
                            onPressed: () {
                               _handlePermission();
                            },
                            icon: Icon(_speechToText.isNotListening
                                ? Icons.mic
                                : Icons.stop),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 48,
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
                          shape: CircleBorder(),
                          elevation: 0.0,
                          shadowColor: Colors.transparent,
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
Future<void> _handlePermission() async {
  // Request microphone permission dynamically
  PermissionStatus status = await Permission.microphone.request();
  if (status.isGranted) {
    _speechToText.isNotListening ? _startListening() : _stopListening();
  } else if (status.isDenied) {
    // Permission denied by the user
    // Handle the situation, maybe show a dialog or message
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied by the user, open app settings
    openAppSettings();
  }
}

  List<String> guesses = [
    "oya kwd",
    "ඔයා",
    "ඔයා කවුද?",
    "ඔයා කවුද",
    "ඔයා කවුද හැදුවෙ",
    "කව්ද"
    "කව්ද හැදුවෙ",
    "ඔයා",
    "ඔයා කව්ද",
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
            "මම හෙළ GPT, LankaTech Innovations හී නිර්මාතෘ වන P.W.R නිමන්‍ත පෙරේරා විසින් නිර්මාණය කරන ලද භාෂා ආකෘතියකි. ඔබට අවශ්‍ය විය හැකි ඕනෑම ප්‍රශ්නයක් හෝ තොරතුරු සමඟ ඔබට සහාය වීමට මම මෙහි සිටිමි. කොහොමද මම අද ඔබට උපකාර කළ හැක්කේ කෙසේද?");
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

final FlutterTts flutterTts = FlutterTts();

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final String img_url;

  const ChatBubble({Key? key, required this.message, required this.img_url})
      : super(key: key);

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Future<void> speakSinhala(String text) async {
    await flutterTts.setLanguage("si-LK");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);

    setState(() {
      isSpeaking = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.message.user == you;
    final ThemeData theme = isCurrentUser ? lightTheme : darkTheme;

    return ListTile(
      leading: isCurrentUser
          ? null
          : CircleAvatar(
              backgroundImage: AssetImage('assets/images/lion_avetar.png'),
              backgroundColor: Colors.transparent,
            ),
      trailing: isCurrentUser
          ? CircleAvatar(
              backgroundImage: NetworkImage(widget.img_url),
            )
          : null,
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
              widget.message.text,
              style: GoogleFonts.notoSerifSinhala(
                color: isCurrentUser
                    ? Colors.white
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              if (!isCurrentUser)
                IconButton(
                  onPressed: () {
                    if (isSpeaking) {
                      stopSpeaking();
                    } else {
                      speakSinhala(widget.message.text);
                    }
                    setState(() {
                      isSpeaking = !isSpeaking;
                    });
                  },
                  icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
                ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  DateFormat.Hm().format(widget.message.createdAt),
                  textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
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

// Asynchronous function to speak the provided text in Sinhala language using FlutterTTS.

Future<void> stopSpeaking() async {
  await flutterTts.stop();
}
