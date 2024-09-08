import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferDetailScreen extends StatelessWidget {
  final Map<String, dynamic> offer;

  const OfferDetailScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          offer['title'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              image: NetworkImage(
                offer['largeImage'] ??
                    'assets/images/default_offer.png', // Handle cases where largeImage might be null
              ),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              offer['title'] ?? 'No Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer['subtitle'] ?? 'No Subtitle',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How to complete this offer:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer['description'] ?? 'No Description Available',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Amount: ₹ ${offer['amount'] ?? '0'}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Colors.purple,
                    Colors.pink,
                    Colors.red,
                  ],
                ),
              ),
              child: TextButton(
                onPressed: () async {
                  final url = offer['actionUrl'] ?? 'https://www.example.com';
                  if (!await launchUrl(Uri.parse(url))) {
                    throw 'Could not launch $url';
                  }
                },
                child: const Text(
                  "Complete Offer",
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
    );
  }
}
