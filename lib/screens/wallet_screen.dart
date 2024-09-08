import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reward_boy/screens/payout_screen.dart';
import 'package:reward_boy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map<String, dynamic>> _payoutItems = [];
  String _coins = "0";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _fetchPayouts();
  }

  Future<void> _loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _coins = prefs.getString('walletBalance') ?? "0";
    });
  }

  Future<void> _fetchPayouts() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? securityToken = prefs.getString('token');

    if (userId == null || securityToken == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Map<String, String> allInfo = await Utils.collectAllInfo();
      String versionName = allInfo['versionName'] ?? "";
      String versionCode = allInfo['versionCode'] ?? "";
      final dio = Dio();
      final response = await dio.post(
        "${allInfo["baseUrl"]}payouts",
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": versionName,
          "versionCode": versionCode,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 200) {
        final payouts = response.data['payouts'] as List<dynamic>;
        setState(() {
          _payoutItems = payouts.map((payout) {
            return {
              'id': payout['id'] ?? '',
              'title': payout['title'] ?? '',
              'image': payout['image'] ?? '',
              'amounts': payout['amounts'].split(",") as List<dynamic>,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'My Wallet',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 39, 162, 176),
                            Color.fromARGB(255, 30, 142, 233),
                            Color.fromARGB(255, 54, 60, 244),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                  "Your Current Coins",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.monetization_on,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _coins,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "100 coins = 1 INR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const Align(
                              alignment: Alignment.bottomRight,
                              child: Opacity(
                                opacity: 0.5,
                                child: Icon(
                                  Icons.currency_rupee,
                                  size: 150,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Redeem Coins",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: _payoutItems.length,
                      itemBuilder: (context, index) {
                        final payout = _payoutItems[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PayoutScreen(
                                  payoutItems: payout['amounts'],
                                  image: payout["image"],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image(
                                  image: NetworkImage(payout["image"]),
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.black.withOpacity(0.3),
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    payout['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
