import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reward_boy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reward_boy/screens/home_screen.dart';
import 'package:reward_boy/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleAppOpen();
  }

  Future<void> _handleAppOpen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    String? securityToken = prefs.getString('token');

    if (userId == null || securityToken == null) {
      _navigateToHomeOrLogin(isLoggedIn: false);
      return;
    }

    Map<String, String> allInfo = await Utils.collectAllInfo();
    String versionName = allInfo['versionName'] ?? "";
    String versionCode = allInfo['versionCode'] ?? "";

    try {
      final Dio dio = Dio();
      final response = await dio.post(
        "${allInfo["baseUrl"]}appOpen",
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": versionName,
          "versionCode": versionCode,
        },
      );

      if (response.statusCode == 201 && response.data["status"] == 200) {
        await _saveUserData(prefs, response.data);
        _navigateToHomeOrLogin(isLoggedIn: true);
      } else {
        prefs.setBool('isLoggedIn', false);
        _showErrorSnackBar("Something Went Wrong");
        _navigateToHomeOrLogin(isLoggedIn: false);
      }
    } catch (e) {
      _showErrorSnackBar("Something Went Wrong");
      _navigateToHomeOrLogin(isLoggedIn: false);
    }
  }

  Future<void> _saveUserData(
      SharedPreferences prefs, Map<String, dynamic> data) async {
    prefs.setString("walletBalance", data['walletBalance'].toString());
    prefs.setString("name", data['name'].toString());
    prefs.setString("image", data['image'].toString());
    prefs.setString("email", data['email'].toString());
    prefs.setString("referCode", data['referCode']);
  }

  void _navigateToHomeOrLogin({required bool isLoggedIn}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: size.width * 0.4,
                  height: size.height * 0.25,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        size: 100, color: Colors.red);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Powered by ',
                    style: TextStyle(
                        fontSize: size.width * 0.04, color: Colors.white),
                  ),
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: size.width * 0.04,
                  ),
                  Text(
                    ' QuizBox',
                    style: TextStyle(
                        fontSize: size.width * 0.04, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
