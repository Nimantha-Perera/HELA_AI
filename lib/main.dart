import 'package:flutter/material.dart';
import 'package:hela_ai/screens/hela_ai.dart';
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
          home: HelaAI(),
        );
      },
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}
