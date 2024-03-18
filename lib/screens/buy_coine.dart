import 'package:flutter/material.dart';
import 'package:hela_ai/ads/reword_ads.dart';

class CoinBuyScreen extends StatefulWidget {
  @override
  _CoinBuyScreenState createState() => _CoinBuyScreenState();
}
RewordAdManager adManager = RewordAdManager();

class _CoinBuyScreenState extends State<CoinBuyScreen> {
  int _selectedPackageIndex = -1;

  List<Map<String, dynamic>> _coinPackages = [
    {'coins': 250, 'price': '\LKR 200'},
    {'coins': 500, 'price': '\LKR 350'},
    {'coins': 1000, 'price': '\LKR 500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
      ),
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
          // For example: navigate to ad watching screen
          adManager.loadRewordAd();
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
      // Implement logic to purchase coins
      // For example: initiate payment process
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
          SizedBox(height: 20), // Add some space between text and button
          ElevatedButton(
            onPressed: () {
              // Implement logic to handle coin purchase
              // For example: initiate payment process
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

}
