import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinsUpdate {
  static Future<void> updateCoins(int earnedCoins) async {
    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get the current coins from Firestore
      int currentCoins = await getCurrentCoins();

      // Calculate updated coins
      int updatedCoins = currentCoins - earnedCoins;

      // Update the 'coins' field with the new value
      await FirebaseFirestore.instance
          .collection('users_google')
          .doc(uid)
          .update({'coins': updatedCoins});

      print('Coins updated successfully in Firestore!');
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating coins in Firestore: $error');
    }
  }
  static Future<void> updateCoinsPlus(int earnedCoins) async {
    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get the current coins from Firestore
      int currentCoins = await getCurrentCoins();

      // Calculate updated coins
      int updatedCoins = currentCoins + earnedCoins;

      // Update the 'coins' field with the new value
      await FirebaseFirestore.instance
          .collection('users_google')
          .doc(uid)
          .update({'coins': updatedCoins});

      print('Coins updated successfully in Firestore!');
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating coins in Firestore: $error');
    }
  }

  static Future<int> getCurrentCoins() async {
    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get a reference to the user's document in Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users_google')
          .doc(uid)
          .get();

      // Check if the document exists and contains the 'coins' field
      if (userSnapshot.exists) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        // Check if userData is not null and contains the 'coins' field
        if (userData != null && userData.containsKey('coins')) {
          // Retrieve the value of the 'coins' field
          int coins = userData['coins'];
          return coins;
        }
      }

      // If the document doesn't exist, or userData is null, or it doesn't contain the 'coins' field, return 0
      return 0;
    } catch (error) {
      // Handle any errors that occur during the retrieval process
      print('Error fetching coins from Firestore: $error');
      return 0; // Return 0 if unable to fetch current coins
    }
  }
}
