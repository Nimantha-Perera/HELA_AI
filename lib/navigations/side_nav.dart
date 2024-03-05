import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/screens/privacy_policy.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:provider/provider.dart';
// Import your ThemeProvider class

class SideNav extends StatelessWidget {
  final UserModal user;

  
  const SideNav({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 109, 109, 109),
              image: DecorationImage(
                image: AssetImage('assets/images/back-dark.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.zero, // Remove default border radius
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome ${user.name}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'හෙළ GPT අපේ දෙයක්',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text('Home'),
          //   onTap: () {
          //     // Add functionality for Home
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.account_circle),
          //   title: Text('Profile'),
          //   onTap: () {
          //     // Add functionality for Profile
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.brightness_6), // Icon for dark mode toggle
            title: Text(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? 'Light Mode'
                  : 'Dark Mode',
            ),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(Icons.logout), // Icon for dark mode toggle
            title: Text(
             'Logout',
            ),
            onTap: () {
              _handleLogOut(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.privacy_tip), // Icon for dark mode toggle
            title: Text(
             'Privacy Policy',
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          ListTile(
            title: Center(
              child: Text(
                'App Version 1.0.0', // Replace with your actual app version
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
          // Add more ListTiles for additional items
        ],
      ),
    );
  }



  void _handleLogOut(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    
    // Sign out from Google account
    await _googleSignIn.signOut();

    // Additional logout logic, if needed (e.g., clear user session)

    // Navigate to the login screen or initial screen
     // Navigate to the login screen
     Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
  }
}
