import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:walkietaskv2/models/Policy.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';


class AddProyects extends StatefulWidget {

  AddProyects(this.myUserRes, this.listUserRes);

  final Usuario myUserRes;
  final List<Usuario> listUserRes;

  @override
  _AddProyectsState createState() => _AddProyectsState();
}

class _AddProyectsState extends State<AddProyects> {

  Usuario myUser;
  double alto = 0;
  double ancho = 0;

  bool cargando = false;
  bool iconBuscador = false;

  List<Usuario> listUser;
  Map<int,bool> checkUser = {};

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryBold;

  TextEditingController controlleBuscador;
  TextEditingController controlleNewName;

  conexionHttp connectionHttp = new conexionHttp();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlleBuscador = TextEditingController();
    controlleNewName = TextEditingController();
    myUser = widget.myUserRes;
    listUser = widget.listUserRes;
  }

  @override
  Widget build(BuildContext context) {
    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;
    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.024, color: WalkieTaskColors.color_969696);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text('Nuevo proyecto',
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696), textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            child: Center(
              child: Container(
                width: ancho * 0.1,
                height: alto * 0.06,
                child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
              ),
            ),
          ),
        ),
      ),
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
        margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05),
        child: Column(
          children: <Widget>[
            SizedBox(height: alto * 0.03,),
            Container(
              width: ancho,
              child: Text('Nombre', style: textStylePrimaryBold,),
            ),
            SizedBox(height: alto * 0.005,),
            Container(
              height: alto * 0.04,
              child: TextFildGeneric(
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.8,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                textEditingController: controlleNewName,
                initialValue: null,
              ),
            ),
            SizedBox(height: alto * 0.025,),
            Container(
              width: ancho,
              child: Text('Usuarios invitados:', style: textStylePrimaryBold,),
            ),
            SizedBox(height: alto * 0.01,),
            buscador(),
            SizedBox(height: alto * 0.01,),
            _invitados(),
            SizedBox(height: alto * 0.05,),
            RoundedButton(
              backgroundColor: WalkieTaskColors.primary,
              title: 'Aceptar',
              onPressed: () => _sumit(),
              radius: 5.0,
              textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
              width: ancho * 0.3,
              height: alto * 0.035,
            ),
          ],
        ),
      ),
    );
  }

  Widget buscador(){
    return Container(
      child: Row(
        children: <Widget>[
          Container(
            child: Text('Buscar',style: textStylePrimary),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: ancho * 0.03),
              height: alto * 0.04,
              child: TextFildGeneric(
                onChanged: (text) {
                  //controlleBuscador.text = value;
                  if(text.length > 0){
                    iconBuscador = true;
                  }else{
                    iconBuscador = false;
                  }
                  setState(() {});
                },
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.8,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                suffixIcon: InkWell(
                  child: iconBuscador ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: (){
                    if(iconBuscador){
                      //controlleBuscador.text = '';
                      iconBuscador = false;
                      //controlleBuscador.clear();
                      WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscador.clear());
                      setState(() {});
                    }
                  },
                ),
                textEditingController: controlleBuscador,
                initialValue: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _invitados(){

    return Container(
      width: ancho,
      height: alto * 0.3,
      padding: EdgeInsets.only(top: alto * 0.005),
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        border: new Border.all(
          width: 1.0,
          color: WalkieTaskColors.grey,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: listUser.map((user) => _cardInvitation(user)).toList(),
        ),
      ),
    );
  }

  Widget _cardInvitation(Usuario user){
    Image avatarUser = Image.network(avatarImage);
    if(user.avatar != ''){
      avatarUser = Image.network('$directorioImage${user.avatar}');
    }
    return Container(
      width: ancho,
      margin: EdgeInsets.only(bottom: alto * 0.02),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: ancho * 0.04, right: ancho * 0.02),
            child: CircleAvatar(
              backgroundColor: Colors.grey[500],
              radius: ancho * 0.05,
              backgroundImage: avatarUser.image,
            ),
          ),
          Expanded(
            child: Text(user.name, style: textStylePrimary,),
          ),
          Checkbox(
              value: checkUser[user.id] ?? false,
              materialTapTargetSize: MaterialTapTargetSize.values[1],
              activeColor: WalkieTaskColors.primary,
              onChanged: (value) {
                checkUser[user.id] = value;
                setState(() {});
              })
        ],
      ),
    );
  }

  Future<void> _sumit() async{
    setState(() {
      cargando = true;
    });


    List<int> members = [];
    checkUser.forEach((key, value) {
      if(value){
        members.add(key);}
    });

    if(controlleNewName.text.isNotEmpty){
      if(members.isNotEmpty){
        Map jsonBody = {
          'name': controlleNewName.text,
        };
        for(int x = 0; x < members.length; x++){
          jsonBody['users[$x]'] = '${members[x]}';
        }
        try{
          var response = await connectionHttp.httpCreateProyect(jsonBody);
          var value = jsonDecode(response.body);
          if(value['status_code'] == 201){
            showAlert('Creado con exito.',WalkieTaskColors.color_89BD7D);
            controlleNewName.text = '';
            checkUser = {};
            setState(() {});
          }else{
            showAlert('Error de conexión',WalkieTaskColors.color_E07676);
          }
        }catch(e){
          print(e.toString());
          showAlert('Error de conexión',WalkieTaskColors.color_E07676);
        }
      }else{
        showAlert('Debe seleccionar al menos un contacto.',WalkieTaskColors.color_E07676);
      }
    }else{
      showAlert('Se debe agregar un nombre de proyecto.',WalkieTaskColors.color_E07676);
    }
    setState(() {
      cargando = false;
    });
  }
}
