import 'package:flutter/material.dart';
import 'package:hela_ai/setting_maneger/settign_maneger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingGPT extends StatefulWidget {
  const SettingGPT({Key? key}) : super(key: key);

  @override
  State<SettingGPT> createState() => _SettingGPTState();
}

class _SettingGPTState extends State<SettingGPT> {
  bool _enableAutoVoice = false; // Toggle for Auto Voice
  SettingsManager _settingsManager = SettingsManager();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load saved settings when the widget is initialized
  }

  // Function to load settings from shared preferences

  _loadSettings() async {
    await _settingsManager.loadSettings();
    setState(() {
      _enableAutoVoice = _settingsManager.enableAutoVoice;
    });
  }

  _saveSettings() {
    _settingsManager.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Setting"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable Auto Voice'),
                Switch(
                  
                  value: _enableAutoVoice,
                  onChanged: (value) {
                    setState(() {
                      _enableAutoVoice = value;
                      _settingsManager.toggleAutoVoice(); // Toggle the setting
                      _saveSettings(); // Save the setting when it changes
                    });
                  },
                  activeColor: Colors.blue, // Customizable
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 15),
            // ... (unchanged code)


            
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingGPT(),
  ));
}
