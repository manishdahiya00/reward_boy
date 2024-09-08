import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:reward_boy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpinWheelScreen extends StatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  State<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  String _walletBalance = '0';
  int spinsLeft = 3;
  bool _isSpinning = false;
  final StreamController<int> _controller = StreamController<int>.broadcast();
  final List<String> _prizes = ['1', '5', '3', '4', '2', '7'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (await _has24HoursPassed()) {
      spinsLeft = 3;
      await _updateSpinsLeft(spinsLeft);
      await _updateLastSpinTimestamp();
    } else {
      spinsLeft = prefs.getInt('spinsLeft') ?? 3;
    }

    setState(() {
      _walletBalance = prefs.getString('walletBalance') ?? '0';
    });
  }

  Future<void> _updateLastSpinTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSpinTime', DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> _has24HoursPassed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastSpinTime = prefs.getInt('lastSpinTime');

    if (lastSpinTime == null) {
      return true;
    }

    DateTime lastSpinDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastSpinTime);
    DateTime now = DateTime.now();

    return now.difference(lastSpinDateTime).inHours >= 24;
  }

  Future<void> _updateUserData(double balance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('walletBalance', balance.toString());
  }

  Future<void> _updateSpinsLeft(int spins) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spinsLeft', spins);
  }

  Future<void> _addCoinsToUser(int coins) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, String> allInfo = await Utils.collectAllInfo();
      String? userId = prefs.getString('userId');
      String? securityToken = prefs.getString('token');

      final response = await Dio().post(
        '${allInfo["baseUrl"]}addCoins',
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": allInfo['versionName'] ?? "",
          "versionCode": allInfo['versionCode'] ?? "",
          'coins': coins.toString(),
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 200) {
        final newBalance = double.parse(_walletBalance) + coins;
        await _updateUserData(newBalance);
        setState(() {
          _walletBalance = newBalance.toString();
        });
      }
    } catch (e) {
      print('Failed to add coins: $e');
    }
  }

  void _spinWheel() async {
    if (spinsLeft <= 0 || _isSpinning) {
      print(
          "Spin action blocked: spinsLeft = $spinsLeft, _isSpinning = $_isSpinning");
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final randomIndex = Random().nextInt(_prizes.length);
    print("Spinning wheel, randomIndex: $randomIndex");
    _controller.add(randomIndex);

    final coinsWon = int.parse(_prizes[randomIndex]);

    await _addCoinsToUser(coinsWon);

    setState(() {
      _isSpinning = false;
      spinsLeft--;
    });

    await _updateSpinsLeft(spinsLeft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Spin Wheel',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(300, 300),
              painter: WheelBorderPainter(),
              child: SizedBox(
                height: 300,
                child: FortuneWheel(
                  selected: _controller.stream,
                  items: _prizes.map((prize) {
                    return FortuneItem(
                      child: Text('$prize coins',
                          style: const TextStyle(color: Colors.white)),
                      style: FortuneItemStyle(
                        color: _getColorForPrize(prize),
                        borderColor: Colors.white,
                        borderWidth: 2,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 50),
            spinsLeft > 0
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed:
                        _isSpinning || spinsLeft <= 0 ? null : _spinWheel,
                    child: Text(
                      _isSpinning ? 'Spinning...' : 'Spin ($spinsLeft left)',
                    ),
                  )
                : const Text(
                    'No spins left for today!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Color _getColorForPrize(String prize) {
    switch (prize) {
      case '1':
        return Colors.red;
      case '5':
        return Colors.green;
      case '3':
        return Colors.blue;
      case '4':
        return Colors.purple;
      case '2':
        return Colors.yellow;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

class WheelBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final Paint patternPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double radius = size.width / 2.4;
    final Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius - 2, borderPaint);

    const int patternCount = 30;
    for (int i = 0; i < patternCount; i++) {
      double angle = (2 * pi / patternCount) * i;
      double x1 = center.dx + (radius - 6) * cos(angle);
      double y1 = center.dy + (radius - 6) * sin(angle);
      double x2 = center.dx + (radius - 4) * cos(angle);
      double y2 = center.dy + (radius - 4) * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), patternPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
