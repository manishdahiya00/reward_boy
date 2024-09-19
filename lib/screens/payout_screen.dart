import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reward_boy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayoutScreen extends StatefulWidget {
  final List<dynamic> payoutItems;
  final String image;
  final String title;

  const PayoutScreen(
      {super.key,
      required this.payoutItems,
      required this.image,
      required this.title});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  final TextEditingController _controller = TextEditingController();

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _redeemSubmitAPI(int index, String upiId, String amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? securityToken = prefs.getString('token');

    if (userId == null || securityToken == null) {
      _showToast("User not authenticated.");
      return;
    }

    try {
      Map<String, String> allInfo = await Utils.collectAllInfo();
      String versionName = allInfo['versionName'] ?? "";
      String versionCode = allInfo['versionCode'] ?? "";
      final Dio dio = Dio();
      final response = await dio.post(
        "${allInfo["baseUrl"]}redeemSubmit",
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": versionName,
          "versionCode": versionCode,
          "amount": amount,
          "upiId": upiId,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 200) {
        _showToast('Redeem submitted successfully!');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('walletBalance', response.data["balance"].toString());
      } else {
        _showToast(response.data['message'] ?? 'Something went wrong.');
      }
    } catch (e) {
      _showToast('Failed to redeem: $e');
    }
  }

  void _showRedeemDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Redeem Coins', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.title == "Insta Followers"
                      ? "Enter your instagram ID"
                      : widget.title == "Play Store"
                          ? "Enter your email."
                          : "Enter your UPI ID",
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final enteredUpiId = _controller.text;
                final amount = widget.payoutItems[index];
                if (enteredUpiId.isEmpty) {
                  _showToast('Please enter valid value.');
                } else {
                  _redeemSubmitAPI(index, enteredUpiId, amount.toString());
                  Navigator.of(context).pop();
                  _controller.clear();
                }
              },
              child: const Text(
                'Redeem Now',
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Redeem Payouts',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1,
        ),
        itemCount: widget.payoutItems.length,
        itemBuilder: (context, index) {
          final title = widget.title;
          final amount = widget.payoutItems[index];
          return InkWell(
            onTap: () {
              _showRedeemDialog(index);
            },
            child: Card(
              color: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Stack(
                children: [
                  Image.network(widget.image, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Text(
                      '₹ $amount',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Text(
                      title == "Insta Followers"
                          ? "${(double.parse(amount) / 100).toStringAsFixed(0)} followers"
                          : "",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
