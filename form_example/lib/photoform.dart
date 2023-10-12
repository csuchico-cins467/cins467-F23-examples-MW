import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  late Future<Position> _position;
  String _text = "";
  late StreamSubscription<Position> positionSubscriberStream;
  late Stream<Position> positionStream;
  File? _imageFile;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _submit() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Processing")));
    if (_formKey.currentState!.validate()) {
      if (_imageFile != null) {
        var uuid = const Uuid();
        String uuidString = uuid.v4();
        String downloadURL = await _uploadImage(uuidString);
        await addItem(downloadURL, _controller.text);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Please take a photo")));
      }
    }
  }

  Future<void> addItem(String downloadURL, String title) async {
    Position position = await _position;
    await FirebaseFirestore.instance.collection('photos').add({
      'title': title,
      'url': downloadURL,
      'location': GeoPoint(position.latitude, position.longitude),
      'user': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _uploadImage(String filename) async {
    // Upload the image to Firebase Storage.
    Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: <String, String>{'file': 'image'},
      contentLanguage: 'en',
    );
    UploadTask uploadTask = ref.putFile(_imageFile!, metadata);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    if (kDebugMode) {
      print(downloadURL);
    }
    return downloadURL;
  }

  String? _textValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter some text";
    }
    if (value.contains("@")) {
      return "Do not use @";
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    positionSubscriberStream.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _position = _determinePosition();
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    positionSubscriberStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (kDebugMode) {
        print(position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      }
    });
  }

  void getPhoto() async {
    final ImagePicker picker = ImagePicker();
// Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Add a Photo"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                    controller: _controller,
                    validator: _textValidator,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter some text")),
                ElevatedButton(onPressed: _submit, child: const Text("Submit")),
              ]),
            ),
            Text(_text),
            SizedBox(
                height: 250,
                width: 250,
                child: _imageFile != null
                    ? Image.file(_imageFile!)
                    : Placeholder(
                        fallbackHeight: 100,
                        fallbackWidth: 100,
                        child: Image.network(
                            "https://t3.ftcdn.net/jpg/05/16/27/58/360_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg"),
                      )),
            FutureBuilder(
                future: _position,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        "Position: ${snapshot.data!.latitude}, ${snapshot.data!.longitude}, ${snapshot.data!.accuracy}");
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const CircularProgressIndicator();
                }),
            StreamBuilder(
                stream: positionStream,
                builder:
                    (BuildContext context, AsyncSnapshot<Position> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        "Stream: ${snapshot.data!.latitude}, ${snapshot.data!.longitude}, ${snapshot.data!.accuracy}");
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return const CircularProgressIndicator();
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getPhoto,
        tooltip: 'Get Photo',
        child: const Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
