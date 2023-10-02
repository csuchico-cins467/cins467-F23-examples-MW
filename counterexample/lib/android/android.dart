import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:counterexample/storage.dart';
import 'package:flutter/material.dart';

class MyAndroidApp extends StatelessWidget {
  const MyAndroidApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyAndroidHomePage(title: 'Flutter Android Home Page'),
    );
  }
}

class MyAndroidHomePage extends StatefulWidget {
  MyAndroidHomePage({super.key, required this.title});

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
  State<MyAndroidHomePage> createState() => _MyAndroidHomePageState();
}

class _MyAndroidHomePageState extends State<MyAndroidHomePage> {
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
