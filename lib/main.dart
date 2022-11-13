import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:polybee_v2/views/camera_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/newPlotForm.dart';
import 'views/recordings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "polybee",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/home': (context) => Image.asset('assets/images/logo_white.png'),
        '/camera': (context) {
          return const CameraPage();
        },
      },
      home: const MyHomePage(title: 'Polybee'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    Image.asset('assets/images/logo_white.png'),
    const NewPlotRecordingPage(),
    DownloadPage(),
  ];


  @override
  void initState() {
    super.initState();
    print("current timezone: ${DateTime.now().timeZoneName}");
  }

  var tabTitle = ['Home', 'Create', 'Records'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 167, 211, 231),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 104, 190, 230),
          title: Text("${widget.title} - ${tabTitle[_selectedIndex]}"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                label: 'Camera'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Records',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold),
          onTap: (int index) {
            setState(
              () {
                _selectedIndex = index;
              },
            );
          }),
    );
  }
}
