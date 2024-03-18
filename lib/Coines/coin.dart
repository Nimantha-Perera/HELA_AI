import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Coin {
  int amount;

  Coin(this.amount);

  void updateAmount(int quantity, UpdateType updateType) {
    switch (updateType) {
      case UpdateType.buy:
        amount += quantity;
        break;
      case UpdateType.add:
        amount += quantity;
        break;
      case UpdateType.subtract:
        if (amount - quantity >= 0) {
          amount -= quantity;
        } else {
          print("Insufficient coins");
          return; // Exit the method if insufficient coins
        }
        break;
    }

    // Call Firestore update function after amount is updated
    _updateFirestore(amount);
  }

  Future<void> _updateFirestore(int updatedAmount) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get the current user's UID
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update the 'coins' field in Firestore for the current user
      await firestore.collection('users_google').doc(uid).update({
        'coins': updatedAmount,
      });

      print("Successfully updated coins in Firestore!");
    } catch (error) {
      print("Error updating coins in Firestore: $error");
      // Handle errors as needed
    }
  }
}
Future<int> getCurrentCoins() async {
    try {
      // Get the current user's UID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Get a reference to the user's document in Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users_google').doc(uid).get();

      // Check if the document exists and contains the 'coins' field
      if (userSnapshot.exists) {
        // Cast the data to a Map<String, dynamic>
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

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

enum UpdateType { buy, add, subtract }
