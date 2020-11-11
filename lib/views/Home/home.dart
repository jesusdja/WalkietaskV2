import 'package:flutter/material.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double alto = 0;
  double ancho = 0;

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;


    return Scaffold(
      body: Center(
        child: InkWell(
          child: Card(
            child: Container(
              color: Colors.grey[200],
              height: alto * 0.08,
              width: ancho * 0.5,
              child: Center(
                child: Text('Tareas',style: TextStyle(fontSize: alto * 0.04),),
              ),
            ),
          ),
          onTap: (){
            Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) => new NavigatorBottonPage()));
          },
        ),
      ),
    );
  }
}
