import 'package:flutter/material.dart';

class HeroDetail extends StatelessWidget {
  final String itemId;

  const HeroDetail({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail View - $itemId')),
      body: Center(
        child: Hero(
          tag: itemId, // Tag should match the one used in the Dashboard
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Details for $itemId',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
