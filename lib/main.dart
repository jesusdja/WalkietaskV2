import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'App.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = const MethodChannel('com.imprevia.walkietaskv2/battery');
  String _batteryLevel = 'Unknown battery level.';
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
      print('');
    } catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
      print('');
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  void initState() {
    super.initState();
    //_getBatteryLevel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale('es', 'ES'),
        supportedLocales: [
          const Locale('es', 'ES'), // English
          const Locale('en', 'US'), // English
        ],
        home: App(),
        theme: ThemeData(
          fontFamily: 'helveticaneue',
        )
    );
  }
}

class AppFR extends StatelessWidget {

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('es', 'ES'),
      supportedLocales: [
        const Locale('es', 'ES'), // English
        const Locale('en', 'US'), // English
      ],
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(backgroundColor: Colors.white,body: Center(child: Text('hasError'),),);
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return MyApp();
            //return Scaffold(backgroundColor: Colors.white,body: Center(child: Text('done'),),);
          }
          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(backgroundColor: Colors.white,body: Container(),);
        },
      ),
    );
  }
}