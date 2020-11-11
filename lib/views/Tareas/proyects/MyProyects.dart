import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walkietaskv2/models/Policy.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/proyects/add_proyects.dart';


class MyProyects extends StatefulWidget {

  MyProyects(this.myUserRes, this.listUserRes);

  final Usuario myUserRes;
  final List<Usuario> listUserRes;

  @override
  _MyProyectsState createState() => _MyProyectsState();
}

class _MyProyectsState extends State<MyProyects> {

  Usuario myUser;
  double alto = 0;
  double ancho = 0;
  bool cargando = false;
  List<Usuario> listUser;
  TextStyle textStylePrimary;
  TextEditingController controlleBuscador;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlleBuscador = TextEditingController();
    myUser = widget.myUserRes;
    listUser = widget.listUserRes;
  }

  @override
  Widget build(BuildContext context) {
    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;
    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold);
    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: cargando ? Cargando('Cargando',context) : contenido(),
      ),
    );
  }

  Widget contenido(){
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              width: ancho,
              padding: EdgeInsets.all(alto * 0.015),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new AddProyects(myUser, listUser)));
                  },
                  child: Icon(Icons.add_circle_outline, color: WalkieTaskColors.primary,size: alto * 0.04,),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
