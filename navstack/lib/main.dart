import 'package:flutter/material.dart';
import 'package:navstack/first.dart';
import 'package:navstack/second.dart';

void main() {
  runApp(MaterialApp(
    title: 'Named Routes Demo',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => const FirstRoute(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/second': (context) => const SecondRoute(),
    },
  ));
}
