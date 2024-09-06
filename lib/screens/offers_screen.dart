import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reward_boy/screens/offer_detail_screen.dart';
import 'package:reward_boy/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<Map<String, dynamic>> _offerItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final securityToken = prefs.getString('token');

    if (userId == null || securityToken == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Map<String, String> allInfo = await Utils.collectAllInfo();
      final dio = Dio();
      final response = await dio.post(
        '${allInfo["baseUrl"]}offers',
        data: {
          "userId": userId,
          "securityToken": securityToken,
          "versionName": allInfo['versionName'] ?? "",
          "versionCode": allInfo['versionCode'] ?? "",
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 200) {
        final offers = response.data['offers'] as List<dynamic>;
        setState(() {
          _offerItems = offers.map((offer) {
            return {
              'smallImage': offer['smallImage'] ?? 'assets/images/logo.png',
              'largeImage': offer['largeImage'] ?? 'assets/images/logo.png',
              'title': offer['title'] ?? 'No Title',
              'subtitle': offer['subtitle'] ?? 'No Subtitle',
              'amount': offer['amount']?.toString() ?? '0',
              'actionUrl': offer['actionUrl'] ?? '',
              'description': offer['description'] ?? '',
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
        title: const Text(
          'Offers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _offerItems.isEmpty
              ? const Center(
                  child: Text(
                    'No offers found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _offerItems.length,
                  itemBuilder: (context, index) {
                    final item = _offerItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OfferDetailScreen(
                                offer: item,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item['largeImage']),
                              radius: 20,
                            ),
                            title: Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              item['subtitle'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              "₹ ${item['amount']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
