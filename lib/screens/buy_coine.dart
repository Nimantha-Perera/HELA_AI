import 'package:flutter/material.dart';
import 'package:hela_ai/Coines/coine_update.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lottie/lottie.dart';

class CoinBuyScreen extends StatefulWidget {
  @override
  _CoinBuyScreenState createState() => _CoinBuyScreenState();
}

class _CoinBuyScreenState extends State<CoinBuyScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  int _selectedPackageIndex = -1;

  List<Map<String, dynamic>> _coinPackages = [
    {'coins': "100", 'price': 'LKR 200'},
    {'coins': "250", 'price': 'LKR 350'},
    {'coins': "500", 'price': 'LKR 500'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchases();
  }

  void _initializeInAppPurchases() {
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {}, onError: (error) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            _buildOptionTile('Watch Ads & Earn 10 Coins', 'Earn coins by watching ads'),
            SizedBox(height: 20),
            Text(
              'OR',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ..._coinPackages
                .asMap()
                .entries
                .map(
                  (entry) => _buildPackageTile(entry.key, entry.value),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(Icons.play_circle),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          // Implement logic to watch ads
        },
      ),
    );
  }

  Widget _buildPackageTile(int index, Map<String, dynamic> package) {
    bool isSelected = index == _selectedPackageIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageIndex = index;
        });
        _initiatePurchase(package['coins']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 219, 219, 219) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 134, 134, 134) : Colors.grey,
            width: 2,
          ),
        ),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${package['coins']} Coins',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Color.fromARGB(255, 136, 136, 136) : Color.fromARGB(255, 190, 190, 190),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Price: ${package['price']}',
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? const Color.fromARGB(255, 110, 110, 110) : const Color.fromARGB(255, 194, 194, 194),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _initiatePurchase(package['coins']);
              },
              child: Text(
                'Buy',
                style: TextStyle(fontSize: 16),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  isSelected ? Colors.white : Colors.blueAccent,
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                  isSelected ? Colors.blueAccent : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initiatePurchase(String coins) async {
    // Implement logic to initiate purchase
    // For example:
    // Load product details from your backend or use a predefined product ID
    ProductDetailsResponse productDetails = await _inAppPurchase.queryProductDetails({coins}.toSet());

    if (productDetails.notFoundIDs.isNotEmpty) {
      // Handle case where product details are not found
      print('Product details not found.');
      return;
    }

    // Example: Make the purchase
    PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails.productDetails.first);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending status
        print('Purchase is pending.');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle purchase error
          print('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Handle successful purchase or restore
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Placeholder for purchase verification logic
    return true;
  }

 Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
  int coinsToAdd = 0;

  // Determine the number of coins to add based on the purchase
  if (purchaseDetails.productID == '500') {
    coinsToAdd = 500;
  } else if (purchaseDetails.productID == '100') {
    coinsToAdd = 100;
  } else if (purchaseDetails.productID == '250') {
    coinsToAdd = 250;
  }

  // Add the coins to the user's balance
  await CoinsUpdate.updateCoinsPlus(coinsToAdd);
  await InAppPurchase.instance.restorePurchases();
  // Check if the widget is still mounted before showing the dialog
  if (mounted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: Lottie.network(
                    "https://lottie.host/33858213-1302-46e9-b2e0-8f8851d9cb33/gWMTPIV2pj.json",
                    repeat: false,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                    'Success! You have earned $coinsToAdd coins. Enjoy and make the most out of your experience'),
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
}


  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // Placeholder for handling invalid purchase logic
    print('Invalid purchase. Handle accordingly.');
  }
}


