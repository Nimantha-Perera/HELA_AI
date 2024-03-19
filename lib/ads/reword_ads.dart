import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RewordAdManager {
  InterstitialAd? interstitialAd;
  bool isAdLoading = false; // Track ongoing loading requests
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-7834397003941676/3730705258'
      : 'ca-app-pub-3940256099942544/1712485313';

  void loadRewordAd(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Show CircularProgressIndicator while loading ad
                SizedBox(
                    height:
                        20), // Add spacing between CircularProgressIndicator and text
                Text(
                  'wait for loading your ad', // Message indicating ad is being loaded
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Retrieve current amount of coins asynchronously
      int currentCoins = await getCurrentCoins();

      // Add 20 to the current amount of coins
      int totalCoins = currentCoins + 20;

      if (totalCoins >= 20) {
        RewardedAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            // Called when an ad is successfully received.
            onAdLoaded: (ad) {
              debugPrint('$ad loaded.');
              Navigator.pop(context); // Dismiss the loading dialog
              showRewordAd(context, ad); // Show the rewarded ad
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              debugPrint('RewardedAd failed to load: $error');
              Navigator.pop(context); // Dismiss the loading dialog
            },
          ),
        );
      } else {
        // If total coins are less than 20, do not attempt to load the ad
        Navigator.pop(context); // Dismiss the loading dialog
        print('Error: Insufficient coins to show ad.');
      }
    } catch (error) {
      print('Error loading rewarded ad: $error');
      Navigator.pop(context); // Dismiss the loading dialog
    }
  }

  void showRewordAd(BuildContext context, RewardedAd ad) {
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        // Implement your logic to give rewards here
        // For example, if you are adding coins as a reward:
        num earnedCoins = rewardItem.amount;
        updateCoins(earnedCoins.toInt());

        // Show success dialog after rewarding the user
        showSuccessDialog(context);
      },
    );
  }

  void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Congratulations!'),
        contentPadding: EdgeInsets.zero, // Set contentPadding to zero
        content: Container(
          padding: EdgeInsets.all(20), // Add padding to the container
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200, // Adjust the height of the container containing the Lottie animation
                child: Lottie.network("https://lottie.host/33858213-1302-46e9-b2e0-8f8851d9cb33/gWMTPIV2pj.json", repeat: false),
              ),
              SizedBox(height: 20), // Add spacing between the animation and the text
              Text('You have earned 10 coins!'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}


  Future<void> updateCoins(int earnedCoins) async {
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

  Future<int> getCurrentCoins() async {
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
