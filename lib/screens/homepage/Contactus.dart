import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Email: support@example.com'),
            SizedBox(height: 8),
            Text('Phone: +1 234 567 890'),
            SizedBox(height: 8),
            Text('Address: 123 Commerce St, Shop City'),
          ],
        ),
      ),
    );
  }
}
