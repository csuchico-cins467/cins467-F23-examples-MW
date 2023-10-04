import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counterexample/android/android.dart';
import 'package:counterexample/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  if (kIsWeb) {
    runApp(const MyApp(title: "Web App"));
  } else {
    if (Platform.isAndroid) {
      runApp(const MyAndroidApp());
    } else {
      runApp(const MyApp(
        title: "Other",
      ));
    }
  }
}

class MyApp extends StatelessWidget {
  final String title;

  const MyApp({super.key, required this.title});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo $title'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final CounterStorage storage = CounterStorage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // late Future<int> _counter;
  late Future<Stream<DocumentSnapshot>> _stream;

  Future<void> _incrementCounter() async {
    int count = await widget.storage.readCounter();
    if (count < 10) {
      count++;
    }
    await widget.storage.writeCounter(count);
    // setState(() {
    //   _counter = widget.storage.readCounter();
    // });
  }

  Future<void> _decrementCounter() async {
    int count = await widget.storage.readCounter();
    if (count > 0) {
      count--;
    }
    await widget.storage.writeCounter(count);
    // setState(() {
    //   _counter = widget.storage.readCounter();
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stream = widget.storage.getStream();
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
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: getBodyWidgetList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<Widget> getBodyWidgetList() {
    return <Widget>[
      const Text("Hello World"),
      const Text(
        'You have pushed the button this many times:',
      ),
      FutureBuilder(
        future: _stream,
        builder: (BuildContext context,
            AsyncSnapshot<Stream<DocumentSnapshot>> futurestreamsnapshot) {
          if (futurestreamsnapshot.hasData) {
            return StreamBuilder(
                stream: futurestreamsnapshot.data,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> documentsnapshot) {
                  if (documentsnapshot.hasData) {
                    return Text(
                      documentsnapshot.data!["count"].toString(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  }
                  return const CircularProgressIndicator();
                });
          }
          return const CircularProgressIndicator();
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _decrementCounter,
            child: IconButton(
                onPressed: _decrementCounter,
                tooltip: "Decrement counter by one",
                icon: const Icon(Icons.remove)),
          ),
          ElevatedButton(
            onPressed: _incrementCounter,
            child: const Icon(Icons.add),
          ),
        ],
      )
    ];
  }
}
