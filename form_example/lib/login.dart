import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:form_example/main.dart';
import 'package:form_example/photoform.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return getPage();
  }

  Widget getPage() {
    if (googleUser == null) {
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
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Photos Page"),
          actions: [
            IconButton(
                onPressed: _handleSignOut, icon: const Icon(Icons.logout))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getBody(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
            tooltip: 'Add a Photo',
            child: const Icon(Icons.add_a_photo)),
      );
    }
  }

  List<Widget> getBody() {
    List<Widget> body = [];
    if (googleUser != null) {
      body.add(StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("photos")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];
                        return Card(
                          child: Column(children: [
                            ListTile(title: Text(documentSnapshot["title"])),
                            Image(
                              image: NetworkImage(documentSnapshot["url"]),
                            )
                          ]),
                        );
                      }));
            }
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return const CircularProgressIndicator();
          }));
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
