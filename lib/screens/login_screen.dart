// login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/screens/hela_ai.dart';
 // Import your home screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              "Welcome to the හෙළ GPT",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                UserModal? user = await _handleSignIn();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HelaAI(user: user),
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

  Future<UserModal?> _handleSignIn() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // You can extract the name and email from the account and create a UserModal
      String name = account?.displayName ?? "";
      String email = account?.email ?? "";

      return UserModal(name: name, email: email);
    } catch (error) {
      print(error);
      return null;
    }
  }
}
