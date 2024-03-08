import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hela_ai/setting_maneger/settign_maneger.dart';
import 'package:hela_ai/themprovider/theam.dart';
import 'package:hela_ai/themprovider/theamdata.dart';
import 'package:provider/provider.dart';

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
    _saveSettings();
    _loadSettings();
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
              'Voice',
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
                      _settingsManager.toggleAutoVoice();
                      _saveSettings();
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 15),
            Text(
              'Theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Mode'),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.blue,
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
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Builder(
        builder: (context) => MaterialApp(
          home: SettingGPT(),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Provider.of<ThemeProvider>(context).isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      ),
    ),
  );
}
