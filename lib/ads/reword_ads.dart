import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewordAdManager {
  InterstitialAd? interstitialAd;
  bool isAdLoading = false; // Track ongoing loading requests
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  void loadRewordAd() async {
    try {
      // Retrieve current amount of coins asynchronously
      int currentCoins = await getCurrentCoins();

      // Add 20 to the current amount of coins
      int totalCoins = currentCoins + 20;

      // Check if the total coins is greater than or equal to 20 before showing the ad
      if (totalCoins >= 20) {
        RewardedAd.load(
          adUnitId: adUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            // Called when an ad is successfully received.
            onAdLoaded: (ad) {
              debugPrint('$ad loaded.');
              showRewordAd(ad);
            },
            // Called when an ad request failed.
            onAdFailedToLoad: (LoadAdError error) {
              debugPrint('RewardedAd failed to load: $error');
            },
          ),
        );
      }
    } catch (error) {
      print('Error loading rewarded ad: $error');
    }
  }

  void showRewordAd(RewardedAd ad) {
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        // Reward the user for watching an ad.
        // Implement your logic to give rewards here
        // For example, if you are adding coins as a reward:
        num earnedCoins = rewardItem.amount;
        updateCoins(earnedCoins.toInt());
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
