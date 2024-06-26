import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hela_ai/screens/hela_ai.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:provider/provider.dart';
import 'package:hela_ai/themprovider/theamdata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC0aBHLzGXrStv-kmpTPncAMKO5k86QUt8",
        authDomain: "helagpt.firebaseapp.com",
        projectId: "helagpt",
        storageBucket: "helagpt.appspot.com",
        messagingSenderId: "189523470100",
        appId: "1:189523470100:web:06827624d648b164c10401",
        measurementId: "G-941Y2M39DK",
      ),
    );
  }

  // Check if the user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  UserModal? user;
  if (isLoggedIn) {
    String name = prefs.getString('name') ?? "";
    String email = prefs.getString('email') ?? "";
    String uid = prefs.getString('uid') ?? "";
    String img_url = prefs.getString('img_url') ?? "";

    if (name.isNotEmpty && email.isNotEmpty && uid.isNotEmpty) {
      user = UserModal(name: name, email: email, img_url: img_url, uid: uid);
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(user: user),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserModal? user;

  const MyApp({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.currentTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: user == null ? LoginScreen() : HelaAI(user: user!, img_url: user!.img_url),
        );
      },
    );
  }
}
