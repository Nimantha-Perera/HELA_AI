import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
var updateInfo = await InAppUpdate.checkForUpdate();
if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
  // Handle update available case
 void showUpdateDialog(BuildContext context) {
  showDialog(
    context: context, // Pass context as an argument here
    builder: (BuildContext context) {
      // Use the passed-in context here
      return AlertDialog(
        title: Text('Update Available'),
        content: Text('A new version of the app is available.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              update(context); // Call the update function
            },
            child: Text('Update Now'),
          ),
        ],
      );
    },
  );
}

} else {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}
}

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

void update(BuildContext context) async {
  print('Updating');
  try {
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
            }
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              // App Update successful
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    });
  } catch (e) {
    print('Error updating: $e');
    // Handle error updating here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Error'),
          content: Text('An error occurred while updating the app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


void handleUpdateError(PlatformException error, BuildContext context) {
  if (error.code == 'TASK_FAILURE' && error.message?.contains('ERROR_APP_NOT_OWNED') == true) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Failed'),
          content: Text('The app update could not be completed because the current user does not own the app. To update the app, please visit the Play Store.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


