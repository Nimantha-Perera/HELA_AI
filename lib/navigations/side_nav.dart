import 'package:flutter/material.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:provider/provider.dart';
 // Import your ThemeProvider class

class SideNav extends StatelessWidget {
  const SideNav({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 109, 109, 109),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Welcome to හෙළ GPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Explore the GPT World',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
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
            title: Text('Toggle Dark Mode'),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
}
