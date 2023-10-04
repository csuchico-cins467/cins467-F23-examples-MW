import 'package:flutter/material.dart';
import 'package:navstack/first.dart';
import 'package:navstack/second.dart';

Widget getDrawer(context) {
  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text('Tinder for Cats'),
        ),
        ListTile(
          title: const Text('Profile'),
          onTap: () {
            // Update the state of the app.
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const FirstRoute()),
                (route) => false);
          },
        ),
        ListTile(
          title: const Text('Matches'),
          onTap: () {
            // Update the state of the app.
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SecondRoute()),
                (route) => false);
          },
        ),
      ],
    ),
  );
}
