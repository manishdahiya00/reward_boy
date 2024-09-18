import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:advertising_id/advertising_id.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reward_boy/screens/home_screen.dart';
import 'package:reward_boy/utils.dart';
import 'package:reward_boy/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> handleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = await AuthService.signInWithGoogle();
      if (googleUser == null) {
        return;
      }

      String adId = await _getAdvertisingId();

      Map<String, String> allInfo = await Utils.collectAllInfo();
      var data = _prepareSignupData(googleUser, allInfo, adId);

      Response response = await Dio().post(
        "${allInfo["baseUrl"]}userSignup",
        data: data,
      );

      if (response.statusCode == 201 && response.data["status"] == 200) {
        await _storeUserData(response.data);

        // Call app open API after successful login
        await _callAppOpenAPI(allInfo);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print("Error during sign-up: ${response.data['message']}");
      }
    } catch (error) {
      print("Sign-In error: $error");
    }
  }

  Future<void> _callAppOpenAPI(Map<String, String> allInfo) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? securityToken = prefs.getString('token');

      if (userId == null || securityToken == null) {
        print("User ID or security token is missing");
        return;
      }

      String versionName = allInfo['versionName'] ?? "";
      String versionCode = allInfo['versionCode'] ?? "";

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
      } else {
        print("Error during app open API call: ${response.data['message']}");
      }
    } catch (error) {
      print("App open API error: $error");
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

  Future<String> _getAdvertisingId() async {
    try {
      return await AdvertisingId.id(true) ?? '';
    } catch (error) {
      return '';
    }
  }

  Map<String, String> _prepareSignupData(GoogleSignInAccount googleUser,
      Map<String, String> allInfo, String adId) {
    return {
      "socialName": googleUser.displayName ?? "Unknown",
      "socialEmail": googleUser.email,
      "deviceId": allInfo['deviceId'] ?? "",
      "deviceType": allInfo['deviceType'] ?? "",
      "deviceName": allInfo['deviceName'] ?? "",
      "advertisingId": adId,
      "versionName": allInfo['versionName'] ?? "",
      "versionCode": allInfo['versionCode'] ?? "",
      "socialType": 'Google',
      "socialImgUrl": googleUser.photoUrl ?? '',
      "utmSource": allInfo['utmSource'] ?? '',
      "utmMedium": allInfo['utmMedium'] ?? '',
      "utmCampaign": allInfo['utmCampaign'] ?? '',
      "utmContent": allInfo['utmContent'] ?? '',
      "utmTerm": allInfo['utmTerm'] ?? '',
      "referrerUrl": allInfo['referrerUrl'] ?? ''
    };
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    String userId = data['userId'] ?? '';
    String token = data['securityToken'] ?? '';

    if (userId.isNotEmpty && token.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userId);
      await prefs.setString('token', token);
    } else {
      print("Error: userId or token is null or empty.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login_screen.png',
                height: size.height * 0.35,
                width: size.width * 0.6,
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                'Welcome to Quiz Box!',
                style: TextStyle(
                  fontSize: size.width * 0.07,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                'Get rewards on daily check-ins, spin the wheel, and more by completing offers!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              ElevatedButton.icon(
                onPressed: () async {
                  await handleSignIn(context);
                },
                icon: const Icon(Icons.login, color: Colors.white, size: 24.0),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.1, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
