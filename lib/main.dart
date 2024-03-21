import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hela_ai/screens/agreement.dart';
import 'package:hela_ai/screens/hela_ai.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:hela_ai/update/update.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:hela_ai/themprovider/theamdata.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() async {
   
   WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase

 if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp( options: const FirebaseOptions(
          apiKey: "AIzaSyC0aBHLzGXrStv-kmpTPncAMKO5k86QUt8",
          authDomain: "helagpt.firebaseapp.com",
          projectId: "helagpt",
          storageBucket: "helagpt.appspot.com",
          messagingSenderId: "189523470100",
          appId: "1:189523470100:web:06827624d648b164c10401",
          measurementId: "G-941Y2M39DK"));
}

  // Check for updates
// var updateInfo = await InAppUpdate.checkForUpdate();
// if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//   // Handle update available case
//  void showUpdateDialog(BuildContext context) {
//   showDialog(
//     context: context, // Pass context as an argument here
//     builder: (BuildContext context) {
//       // Use the passed-in context here
//       return AlertDialog(
//         title: Text('Update Available'),
//         content: Text('A new version of the app is available.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context); // Close the dialog
//               update(context); // Call the update function
//             },
//             child: Text('Update Now'),
//           ),
//         ],
//       );
//     },
//   );
// }

// } else {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.currentTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: UserAgreement(),
        );
      },
    );
  }
}









