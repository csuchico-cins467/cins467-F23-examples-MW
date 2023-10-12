import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_example/login.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

void main() {
  runApp(const MaterialApp(
    title: "Login Page",
    home: LoginPage(),
  ));
}
