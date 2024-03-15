import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hela_ai/screens/agreement.dart';
import 'package:hela_ai/screens/hela_ai.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:hela_ai/themprovider/theamdata.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase

 await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyC0aBHLzGXrStv-kmpTPncAMKO5k86QUt8",
          authDomain: "helagpt.firebaseapp.com",
          projectId: "helagpt",
          storageBucket: "helagpt.appspot.com",
          messagingSenderId: "189523470100",
          appId: "1:189523470100:web:06827624d648b164c10401",
          measurementId: "G-941Y2M39DK"));
  

  // Check for updates
  // var updateInfo = await InAppUpdate.checkForUpdate();
  // if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
  //   // Handle update available case
  //   update();
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

void update() async {
  print('Updating');
  await InAppUpdate.startFlexibleUpdate();
  InAppUpdate.checkForUpdate().then((updateInfo) {
  if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
              if (appUpdateResult == AppUpdateResult.success) {
                //App Update successful
              }
          });
      } else if (updateInfo.flexibleUpdateAllowed) {
        //Perform flexible update
        InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
              if (appUpdateResult == AppUpdateResult.success) {
                //App Update successful
                InAppUpdate.completeFlexibleUpdate();
              }
          });
      }
  }
});
}
