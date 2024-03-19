import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hela_ai/ads/reword_ads.dart';
import 'package:hela_ai/feedback/feedback.dart';

import 'package:hela_ai/get_user_modal/user_modal.dart';
import 'package:hela_ai/screens/buy_coine.dart';
import 'package:hela_ai/screens/img_to_text.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:hela_ai/screens/privacy_policy.dart';
import 'package:hela_ai/screens/setting.dart';
import 'package:hela_ai/screens/text_to_image.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your ThemeProvider class
RewordAdManager adManager = RewordAdManager();

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
          //   leading: Icon(Icons.account_circle),
          //   title: Text('Profile'),
          //   onTap: () {
          //     // Add functionality for Profile
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.brightness_6), // Icon for dark mode toggle
          //   title: Text(
          //     Provider.of<ThemeProvider>(context).isDarkMode
          //         ? 'Light Mode'
          //         : 'Dark Mode',
          //   ),
          //   onTap: () {
          //     Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // Add functionality for reword
                // adManager.loadRewordAd();
                Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CoinBuyScreen(),
              ));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xEBBD13), // Use color literal for clarity
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Align evenly
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                   
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.coins,
                            color: Color.fromARGB(255, 255, 187, 0),
                          ),
                          const SizedBox(width: 10.0), // Consistent spacing
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users_google')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text(
                                  'Loading...',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 230, 0)),
                                );
                              }

                              final int coins = snapshot.data!['coins'] ?? 0;
                              return Text(
                                '$coins',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 88, 88, 88),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.add_circle_outline,
                      color: Color.fromARGB(255, 138, 138, 138),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ListTile(
            leading:
                Icon(Icons.image_aspect_ratio), // Icon for dark mode toggle
            title: Text(
              'Image Explainer',
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ImageGen(),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings), // Icon for dark mode toggle
            title: Text(
              'Setting',
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingGPT(),
              ));
            },
          ),

          // ListTile(
          //   leading: Icon(Icons.settings), // Icon for dark mode toggle
          //   title: Text(
          //    'Text to Image',
          //   ),
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (context) => TexttoImage(),
          //       )
          //     );
          //   },
          // ),

          ListTile(
            leading: Icon(Icons.image_rounded),
            // Icon for dark mode toggle
            title: Text(
              'Text to Image',
            ),
            onTap: () {
              // adManager.loadRewordAd();
            },
            enabled: false,
          ),

          ListTile(
            leading: Icon(Icons.logout), // Icon for dark mode toggle
            title: Text(
              'Logout',
            ),
            onTap: () {
              _clearUserData();
              _handleLogOut(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback), // Icon for dark mode toggle
            title: Text(
              'Feedback',
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FeedbackScreen(),
              ));
            },
          ),

          // ListTile(
          //   leading: Icon(Icons.privacy_tip), // Icon for dark mode toggle
          //   title: Text(
          //     'Privacy Policy',
          //   ),
          //   onTap: () {
          //     Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) => PrivacyPolicyScreen(),
          //     ));
          //   },
          // ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ListTile(
              title: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen(),
                        ));
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Color.fromARGB(255, 117, 117, 117),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'App Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
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
    try {
      await FirebaseAuth.instance.signOut();
      await _clearUserData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('name');
    prefs.remove('email');
    prefs.remove('uid');
    prefs.remove('img_url');
  }
}
