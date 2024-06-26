import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/screens/hela_ai.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              "හෙළ GPT",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Lottie.asset("assets/images/brane.json", width: 200, height: 200),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                UserModal? user = await _handleSignIn();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HelaAI(user: user, img_url: user.img_url),
                    ),
                  );
                }
              },
              child: Text('GOOGLE SIGN IN'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // _checkLoggedInUser();
  }

  // Future<void> _checkLoggedInUser() async {
  // //   final prefs = await SharedPreferences.getInstance();
  // //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // //   print("Is User Logged In: $isLoggedIn");

  // //   if (isLoggedIn) {
  // //     UserModal? user = await _fetchUserData();
  // //     print("User Data: $user"); // Add this line to check user data

  // //     if (user != null) {
  // //       Navigator.pushReplacement(
  // //         context,
  // //         MaterialPageRoute(
  // //           builder: (context) => HelaAI(user: user, img_url: user.img_url),
  // //         ),
  // //       );
  // //     }
  // //   }
  // // }

  Future<UserModal?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        String name = user.displayName ?? "";
        String email = user.email ?? "";
        String uid = user.uid;
        String img_url = user.photoURL ?? "";

        print("User Img Url: $img_url");

        // Check if the user already exists in Firestore
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('users_google')
                .doc(uid)
                .get();

        if (!userDoc.exists) {
          try {
            final firestore = FirebaseFirestore.instance;

            // Add user data to Firestore collection "users_google"
            firestore.collection('users_google').doc(uid).set({
              'name': name,
              'coins': 100,
              // Add other relevant fields here (with appropriate security rules)
            }).then((_) {
              print(
                  "Successfully saved user data to Firestore collection 'users_google'!");
              return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Congratulations!'),
                    contentPadding:
                        EdgeInsets.zero, // Set contentPadding to zero
                    content: Container(
                      padding:
                          EdgeInsets.all(20), // Add padding to the container
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height:
                                200, // Adjust the height of the container containing the Lottie animation
                            child: Lottie.network(
                                "https://lottie.host/33858213-1302-46e9-b2e0-8f8851d9cb33/gWMTPIV2pj.json",
                                repeat: false),
                          ),
                          SizedBox(
                              height:
                                  20), // Add spacing between the animation and the text
                          Text(
                              'Congratulations on your first-time login! You have earned a special reward of 100 coins. Enjoy and make the most out of your experience'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }).catchError((error) {
              print(
                  "Error saving user data to Firestore collection 'users_google': $error");
            });
          } catch (error) {
            print("Error accessing Firestore: $error");
            // Handle general Firestore errors
          }
        } else {
          print("User already exists in Firestore. Skipping registration.");
        }

        // Save login status
        await _saveLoginStatus(true);

        // Save user data
        await _saveUserData(user);

        return UserModal(name: name, email: email, img_url: img_url, uid: uid);
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-disabled') {
        // Display an alert dialog indicating that the user account has been disabled
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Account Disabled"),
              content: Text(
                  "The user account has been disabled by an administrator."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        print(e);
      }
      return null;
    } catch (error) {
      print(error);
      return null;
    }
  }

//   void showSuccessDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Congratulations!'),
//         contentPadding: EdgeInsets.zero, // Set contentPadding to zero
//         content: Container(
//           padding: EdgeInsets.all(20), // Add padding to the container
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 height: 200, // Adjust the height of the container containing the Lottie animation
//                 child: Lottie.network("https://lottie.host/33858213-1302-46e9-b2e0-8f8851d9cb33/gWMTPIV2pj.json", repeat: false),
//               ),
//               SizedBox(height: 20), // Add spacing between the animation and the text
//               Text('Congratulations on your first-time login! You have earned a special reward of 100 coins. Enjoy and make the most out of your experience'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//                Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           HelaAI(user: user, img_url: user.img_url),
//                     ),
//                   );
//             },
//             child: Text('OK'),
//           ),
//         ],
//       );
//     },
//   );
// }

  Future<UserModal?> _fetchUserData() async {
    // Replace this with your logic to fetch user data from storage or backend
    // For example, you can use SharedPreferences or make a network request.
    // Return a UserModal object if user data is available, otherwise return null.
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('name') ?? "";
    String email = prefs.getString('email') ?? "";
    String uid = prefs.getString('uid') ?? "";
    String img_url = prefs.getString('img_url') ?? "";

    if (name.isNotEmpty && email.isNotEmpty && uid.isNotEmpty) {
      return UserModal(name: name, email: email, img_url: img_url, uid: uid);
    } else {
      return null;
    }
  }

  Future<void> _saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.displayName ?? "");
    await prefs.setString('email', user.email ?? "");
    await prefs.setString('uid', user.uid);
    await prefs.setString('img_url', user.photoURL ?? "");
  }
}
