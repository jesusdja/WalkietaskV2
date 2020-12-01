import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/proyects/add_proyects.dart';


class MyProyects extends StatefulWidget {

  MyProyects(this.myUserRes, this.listUserRes, this.blocPage);

  final Usuario myUserRes;
  final List<Usuario> listUserRes;
  final BlocPage blocPage;

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
                        builder: (BuildContext context) => new AddProyects(myUser, listUser, widget.blocPage)));
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
