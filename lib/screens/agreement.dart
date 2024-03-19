import 'package:flutter/material.dart';
import 'package:hela_ai/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAgreement extends StatefulWidget {
  @override
  _UserAgreementState createState() => _UserAgreementState();
}

class _UserAgreementState extends State<UserAgreement> {
  bool agreed = false;

  @override
  Future<void> checkUserAgreement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAgreed =
        prefs.getBool('hasAgreed') ?? false; // Default to false if not set
    setState(() {
      agreed = hasAgreed;
    });

    if (agreed) {
      print('User has already agreed to the terms');
      // Navigate to the next screen or perform desired action
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ));
    } else {
      print('User has not agreed to terms. Display agreement screen.');
      // Call a method to display the agreement content here (e.g., showAgreementDialog())
    }
  }

  void initState() {
    super.initState();
    checkUserAgreement();
  }

  Future<void> saveUserAgreement(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAgreed', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hela GPT User Agreement'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Hela GPT!',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'This User Agreement ("Agreement") governs your use of the Hela GPT mobile application, developed and operated by LankaTech innovations (Pvt) Ltd. By accessing or using the App, you agree to be bound by the terms and conditions of this Agreement.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '1. Eligibility',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You must be at least 14 years of age to use the App. By using the App, you represent and warrant that you meet all of the foregoing eligibility requirements.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '2. User Accounts',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You may be required to create an account to access certain features of the App. You are responsible for maintaining the confidentiality of your account information, including your login credentials, and for all activities that occur under your account.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '3. User Content',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You are solely responsible for any content you submit, post, or upload to the App ("User Content"). You retain all ownership rights in your User Content, but by submitting it, you grant us a non-exclusive, royalty-free, worldwide license to use, reproduce, modify, publish, distribute, and translate your User Content for the purpose of operating and improving the App.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            // Add sections for additional terms as needed (e.g., Intellectual Property, Disclaimers, Limitations of Liability, Termination, Governing Law, Dispute Resolution)
            const Text(
              '4. Intellectual Property',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'The App and its content, including all intellectual property rights, are owned by us or our licensors. You may not use any trademarks, copyrights, or other intellectual property rights of ours or any third party without our prior written consent.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '5. Disclaimers',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Text(
              'The App is provided "as is" and without warranties of any kind, whether express or implied. We disclaim all warranties, including but not limited to, the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            // ... (Continue adding sections for other terms)

            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: agreed,
                  onChanged: (value) {
                    setState(() {
                      agreed = value!;
                    });
                  },
                ),
                Text('I agree to the terms and conditions'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (agreed) {
                      // Navigate to the next screen or perform desired action
                      // when the user agrees to the terms
                      print('User agreed to terms.');
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool('hasAgreed',
                          true); // Set agreed flag in SharedPreferences
                      setState(() {
                        agreed = true;
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ));
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Agreement Required'),
                          content: Text(
                              'You must agree to the terms and conditions to continue.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Agree'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Perform action when the user disagrees to the terms
                    print('User disagreed to terms.');
                    checkUserAgreement();
                  },
                  child: Text('Disagree'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserAgreement(),
  ));
}
