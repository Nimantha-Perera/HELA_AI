// login_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/screens/hela_ai.dart';
import 'package:provider/provider.dart';
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
                  context.read<UserProvider>().setUser(user);
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
    
    if (account == null) {
      // User canceled the sign-in process
      return null;
    }

    // Use the Google Sign-In account to sign in with Firebase
    final GoogleSignInAuthentication googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = authResult.user;

    if (user != null) {
      // User signed in successfully
      String name = user.displayName ?? "";
      String email = user.email ?? "";
      String uid = user.uid;

      return UserModal(name: name, email: email, uid: uid);
    } else {
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
}
}
class UserProvider extends ChangeNotifier {
  UserModal? _user;

  UserModal? get user => _user;

  void setUser(UserModal user) {
    _user = user;
    notifyListeners();
  }
}
