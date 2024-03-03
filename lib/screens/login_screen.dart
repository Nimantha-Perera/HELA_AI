import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            _handleSignIn();
          },
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
  try {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    // Handle the signed-in user
    print(account);
  } catch (error) {
    print(error);
  }
}

}

