import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hela_ai/screens/hela_ai.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:provider/provider.dart';
import 'package:hela_ai/themprovider/theamdata.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild MyApp when the theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.currentTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC0aBHLzGXrStv-kmpTPncAMKO5k86QUt8",
          authDomain: "helagpt.firebaseapp.com",
          projectId: "helagpt",
          storageBucket: "helagpt.appspot.com",
          messagingSenderId: "189523470100",
          appId: "1:189523470100:web:06827624d648b164c10401",
          measurementId: "G-941Y2M39DK"));
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}
