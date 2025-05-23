import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final List<String> categories = [
    'Beaches',
    'Mountains',
    'Cities',
    'Islands',
    'Heritage',
    'Nature',
    'Adventure',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.brown.shade700,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(categories[index]),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to selected category's destination list
          },
        ),
      ),
    );
  }
}
