import 'package:flutter/material.dart';
import 'package:navstack/components/drawer.dart';

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      drawer: getDrawer(context),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.popAndPushNamed(context, '/');
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
