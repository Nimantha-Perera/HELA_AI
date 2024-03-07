import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  bool _enableAutoVoice = false;

  bool get enableAutoVoice => _enableAutoVoice;

  // Function to toggle the value of enableAutoVoice
  void toggleAutoVoice() {
    _enableAutoVoice = !_enableAutoVoice;
  }

  // Function to load settings from shared preferences
  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _enableAutoVoice = prefs.getBool('enableAutoVoice') ?? false;
  }

  // Function to save settings to shared preferences
  void saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('enableAutoVoice', _enableAutoVoice);
  }
}