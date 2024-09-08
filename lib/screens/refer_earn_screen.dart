import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  String _referCode = '';

  @override
  void initState() {
    super.initState();
    _setInitialReferCode();
  }

  Future<void> _setInitialReferCode() async {
    final prefs = await SharedPreferences.getInstance();
    String referCode = prefs.getString('referCode') ?? '';

    if (referCode.isEmpty) {
      // Set default code if none is found
      await prefs.setString('referCode', 'DEFAULTCODE123');
      referCode = 'DEFAULTCODE123';
    }

    // Update the state with the fetched refer code
    setState(() {
      _referCode = referCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Refer & Earn',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/refer.png",
                      width: size.width * 0.8,
                      height: size.height * 0.3,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Invite your friends and earn coins!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      width: buttonWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _referCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: buttonWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pink, Colors.red],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await Share.share(
                              'Join RewardBuddy and let the rewards come to you—sign up today and start earning! http://192.168.145.141:3000/invite',
                            );
                          } catch (e) {
                            print('Error sharing: $e');
                          }
                        },
                        child: const Text(
                          "Invite Now!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                "How It Works?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildStep(
                icon: Icons.share,
                title: "Refer Friends",
                description: "Invite your friends to RewardBoy.",
              ),
              const SizedBox(height: 20),
              _buildStep(
                icon: Icons.monetization_on,
                title: "Earn 200 coins",
                description: "Receive 200 coins when they sign up in the app.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.purple, Colors.pink, Colors.red],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
