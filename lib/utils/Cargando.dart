
import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';

Widget Cargando(String texto,BuildContext context){
  return Center(
      child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    WalkieTaskColors.primary,
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.height * 0.1,
              ),
              SizedBox.fromSize(size: Size.fromHeight(30)),
              Text('$texto',style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),)
            ],
          )
      )
  );
}