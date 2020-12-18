import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:walkietaskv2/views/Home/StarLogo.dart';
import 'App.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        home: AppFR(),
        theme: ThemeData(
          fontFamily: 'helveticaneue',
        )
    );
  }
}

class AppFR extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(backgroundColor: Colors.white,body: Center(child: Text('hasError'),),);
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return App();
          //return Scaffold(backgroundColor: Colors.white,body: Center(child: Text('done'),),);
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(backgroundColor: Colors.white,body: Center(child: Text('NADA'),),);
      },
    );
  }
}