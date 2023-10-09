import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:form_example/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _initialized = false;
  GoogleSignInAccount? googleUser;

  Future<void> initializeDefault() async {
    FirebaseApp app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
    if (kDebugMode) {
      print("Initialized default Firebase app $app");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!_initialized) {
      await initializeDefault();
    }
    // Trigger the authentication flow
    googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      if (kDebugMode) {
        print(googleUser!.email);
      }
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    // Once signed in, return the UserCredential
    setState(() {});
    return userCredential;
  }

  Future<void> _handleSignOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    googleSignIn.disconnect();
    setState(() {
      googleUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login Page"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getBody(),
          ),
        ));
  }

  List<Widget> getBody() {
    List<Widget> body = [];
    if (googleUser != null) {
      body.add(ListTile(
        leading: GoogleUserCircleAvatar(identity: googleUser!),
        title: Text(googleUser!.displayName ?? ''),
        subtitle: Text(googleUser!.email),
      ));
      body.add(Text(FirebaseAuth.instance.currentUser!.uid));
      body.add(ElevatedButton(
          onPressed: _handleSignOut, child: const Text("Logout")));
    } else {
      body.add(ElevatedButton(
          onPressed: () {
            signInWithGoogle();
          },
          child: const Text("Login")));
    }
    return body;
  }
}
