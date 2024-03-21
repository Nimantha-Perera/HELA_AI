import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hela_ai/Coines/coin.dart';
import 'package:hela_ai/Coines/coine_update.dart';
import 'package:hela_ai/ads/init_ads.dart';
import 'package:hela_ai/coatchmark_des/coatch_mark_des.dart';
import 'package:hela_ai/screens/buy_coine.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

bool isLoading = false;
 List<TargetFocus> targets = [];

class ImageGen extends StatefulWidget {
  const ImageGen({Key? key}) : super(key: key);

  @override
  _ImageGenState createState() => _ImageGenState();
}

InterstitialAdManager interstitialAdManager = InterstitialAdManager();

class _ImageGenState extends State<ImageGen> {
  File? _selectedImage;
  String? _generatedText;
  String? _translatedText;
  TextEditingController _textInputController = TextEditingController();
  bool _isGenerating = false;
  bool isFirstTime = true;


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      if (isFirstTime) {
        checkTutorialStatus();
        isFirstTime =
            false; // Update the variable to indicate that the tutorial has been shown
      }
     
    });
    interstitialAdManager.initInterstitialAd();
  }
  Future<void> checkTutorialStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isFirstTime = prefs.getBool('isFirstTime_img_to_text') ?? true;

      if (isFirstTime) {
        Future.delayed(Duration(seconds: 1), () {
          showTutorial();
          print("Firstime user");
          prefs.setBool(
              'isFirstTime_img_to_text', false); // Update the variable in SharedPreferences
     
        });
      } else {
        // Tutorial already shown, proceed directly to initSpeech()
        Future.delayed(Duration(seconds: 1), () {
 
          print("2nd time user");
        });
      }
    });
  }

  //Tutorial shownm

   void showTutorial() {
    _initTargets();
    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      targets: targets,
    )..show(context: context);
  }

  // Globle Keys

  GlobalKey gen_btn = GlobalKey();
  GlobalKey pick = GlobalKey();
  GlobalKey text = GlobalKey();
  GlobalKey text_area = GlobalKey();


  // Initialize the targets for the CoachMark library, including menu and share targets.
  void _initTargets() {
    targets = [
      TargetFocus(
        
          identify: "pick_key",
          keyTarget: pick,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                builder: (context, controller) {
                  return CoachMarkDes(
                    text: "පළමුව Image එක Select කරන්න.",
                    onSkip: () {
                      controller.skip();
                    },
                    onNext: () {
                      controller.next();
                    },
                  );
                })
          ]),
      TargetFocus(identify: "text-key",  shape: ShapeLightFocus.RRect, keyTarget: text, contents: [
        
        TargetContent(
          
            align: ContentAlign.bottom,
            
            builder: (context, controller) {
              return CoachMarkDes(
                text: "Promt(ජායාරූපය පිලිබඳ දැනගැනීමට අවශ්‍ය කරුණ) ඇතුලත් කරන්න",
                onSkip: () {
                  controller.skip();
                },
                onNext: () {
                  controller.next();
                },
              );
            })
      ]),
      TargetFocus(identify: "gen-key", keyTarget: gen_btn, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachMarkDes(
                text: "ඉන්පසුව Send කරන්න",
                onSkip: () {
                  controller.skip();
                },
                onNext: () {
                  controller.next();
                },
              );
            })
      ]),
      TargetFocus(identify: "area-key", keyTarget: text_area, contents: [
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _generatedText = null;
        _translatedText = null;
      });
    }
  }

  // Translate and show Gemini content from the given outputText.
  void _translateAndShowGeminiContent(String outputText) {
    translator.translate(outputText, to: 'si').then((value) {
      String translatedText = value.toString();

      print(translatedText);

      setState(() {
        _translatedText = translatedText;
      });
    });
  }

  // A function that translates the input text to English and generates Gemini content based on the translated text.
  void translateAndGenerateGeminiContent(String inputText) {
    translator.translate(inputText, to: 'en').then((value) {
      setState(() {
        String translatedText2 = value.toString();
        print(translatedText2);
        _generateResponse(translatedText2);
      });
    });
  }
  void showAlertDialog(BuildContext context) {
  // Show alert dialog
  
  showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
     
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Oops! It seems like you don\'t have enough coins.',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'OK',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
           Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CoinBuyScreen(),
              ));
          },
          child: Text(
            'BUY COINS',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  },
);

}


  Future<void> _generateResponse(String inputText) async {
    if (_selectedImage == null) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });
    int coins = await getCurrentCoins();
    if (coins < 10) {
       isLoading = false;
        setState(() {
        _isGenerating = false;
      });
      return showAlertDialog(context);
      

    }else{

    try {
      final apiKey = dotenv.env['API_KEY'] ?? "";
      if (apiKey == null) {
        throw ArgumentError('API_KEY environment variable is not set.');
      }

      final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
      final imageBytes = await _selectedImage!.readAsBytes();

      final prompt = TextPart(inputText);
      final imagePart = DataPart('image/jpeg', imageBytes);

      final response = await model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);
      await CoinsUpdate.updateCoins(10);

      print('Generated response: ${response.text}');

      setState(() {
        _generatedText = response.text;

        _translateAndShowGeminiContent(_generatedText!);
      });
    } catch (e) {
      print('Error generating response: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
    }
  }

  GoogleTranslator translator = GoogleTranslator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users_google')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text(
                  'Loading...',
                  style:
                      const TextStyle(color: Color.fromARGB(255, 255, 230, 0)),
                );
              }

              final int coins = snapshot.data!['coins'] ?? 0;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    
                    // Consistent spacing
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 158, 158, 158),
                      ),
                    ),
                    const SizedBox(width: 10.0), 
                    FaIcon(
                      FontAwesomeIcons.coins,
                      color: Color.fromARGB(255, 255, 166, 0),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        title: Text(
          'Image GPT',
          style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 48, 48, 48),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: text,
                        controller: _textInputController,
                        decoration: InputDecoration(
                          labelText: 'Enter Text Prompt',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10.0),
                          prefixIcon: Icon(Icons.architecture),
                        ),
                        onChanged: (text) {
                          setState(
                              () {}); // This triggers a rebuild to update the button state
                        },
                      ),
                    ),
                    IconButton(
                      key: gen_btn,
                      onPressed: _textInputController.text.isNotEmpty &&
                              _selectedImage != null
                          ? () {
                              // Assuming this method shows the ad
                              interstitialAdManager.showInterstitialAd();
                              translateAndGenerateGeminiContent(
                                  _textInputController.text);
                              // Assuming this method shows the ad
                            }
                          : null,
                      icon: Icon(Icons.play_arrow),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildImageInput(),
              SizedBox(height: 20),
              _selectedImage != null
                  ? DisplaySelectedImage(image: FileImage(_selectedImage!))
                  : Text('No image selected'),
              SizedBox(height: 20),
              _isGenerating
                  ? CircularProgressIndicator()
                  : _generatedText != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              _translatedText != null
                                  ? Text(
                                      '$_translatedText',
                                      style: GoogleFonts.notoSerifSinhala(),
                                    )
                                  : Container(),
                            ],
                          ),
                        )
                      : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageInput() {
    return ElevatedButton(
      key: pick,
      onPressed: _pickImage,
      child: Text('Pick Image'),
    );
  }

  Widget _buildGenerateButton(String inputs) {
    String outputText = inputs;
    return IconButton(
      onPressed: _selectedImage != null
          ? () => translateAndGenerateGeminiContent(outputText)
          : null,
      icon: Icon(Icons.play_arrow),
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
