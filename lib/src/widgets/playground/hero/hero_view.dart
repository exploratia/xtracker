import 'package:flutter/material.dart';

import 'hero_detail.dart';

class HeroView extends StatelessWidget {
  const HeroView({super.key});

  static const routeName = '/heroview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        children: [
          ListTile(
            title: const Hero(
              tag: 'item1', // Tag should be unique
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Item 1',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeroDetail(itemId: 'item1'),
                ),
              );
            },
          ),
          ListTile(
            title: const Hero(
              tag: 'item2',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Item 2',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeroDetail(itemId: 'item2'),
                ),
              );
            },
          ),
          ListTile(
            title: const Hero(
              tag: 'item3',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Item 3',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeroDetail(itemId: 'item3'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
