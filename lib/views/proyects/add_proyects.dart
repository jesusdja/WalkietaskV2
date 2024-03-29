import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/proyects/add_proyects_sumit.dart';


class AddProyects extends StatefulWidget {

  AddProyects({this.myUserRes, this.listUserRes, this.blocPage, this.proyect, this.listUsersExist});

  final Usuario myUserRes;
  final List<Usuario> listUserRes;
  final BlocPage blocPage;
  final Caso proyect;
  final List listUsersExist;

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
    super.initState();
    controlleBuscador = TextEditingController();
    controlleNewName = TextEditingController();
    if(widget.proyect != null){
      controlleNewName.text = widget.proyect.name;
    }
    myUser = widget.myUserRes;
    listUser = widget.listUserRes;
  }

  @override
  Widget build(BuildContext context) {
    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;
    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.color_969696,fontWeight: FontWeight.bold,spacing: 0.5);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.022, color: WalkieTaskColors.color_969696);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text(widget.proyect != null ? '' : translate(context: context, text: 'newProject'),
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696), textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(false),
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
        child: cargando ? Cargando(translate(context: context, text: 'loading'),context) : contenido(),
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
              child: Text(translate(context: context, text: 'name'), style: textStylePrimaryBold,),
            ),
            SizedBox(height: alto * 0.005,),
            Container(
              height: alto * 0.04,
              child: widget.proyect != null ?
              Container(
                width: ancho,
                child: Text(widget.proyect.name,style: textStylePrimary,maxLines: 1,),
              )
              :
              TextFildGeneric(
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
              child: Text('${translate(context: context, text: 'invitedUsers')}:', style: textStylePrimaryBold,),
            ),
            SizedBox(height: alto * 0.01,),
            buscador(),
            SizedBox(height: alto * 0.01,),
            _invitados(),
            SizedBox(height: alto * 0.05,),
            RoundedButton(
              backgroundColor: WalkieTaskColors.primary,
              title: translate(context: context, text: 'ok'),
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
            child: Text(translate(context: context, text: 'search'),style: textStylePrimary),
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
                      controlleBuscador.text = '';
                      iconBuscador = false;
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
      padding: EdgeInsets.only(top: alto * 0.01),
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

    if(user.contact == 0 ){ return Container();}

    if((!user.name.toLowerCase().contains(controlleBuscador.text.toLowerCase()) &&
        !user.surname.toLowerCase().contains(controlleBuscador.text.toLowerCase())) &&
        controlleBuscador.text.isNotEmpty){
      return Container();
    }

    if(widget.listUsersExist != null && widget.listUsersExist.isNotEmpty){
      bool exist = false;
      widget.listUsersExist.forEach((userListExist) {
        if(userListExist['users']['id'] == user.id){
          exist = true;
          checkUser[userListExist['users']['id']] = true;
        }
      });
      if(exist){
        return Container();
      }
    }

    String userName = user != null ? user.name ?? '' : '';
    Widget avatarUserWidget = avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase());
    if(user != null && user.avatar_100 != ''){
      avatarUserWidget = avatarWidgetImage(alto: alto,pathImage: user.avatar_100);
    }
    return Container(
      width: ancho,
      margin: EdgeInsets.only(bottom: alto * 0.02),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: ancho * 0.04, right: ancho * 0.02),
            child: avatarUserWidget,
          ),
          Expanded(
            child: Text('${user.name} ${user.surname}', style: textStylePrimary,),
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

    if(controlleNewName.text.isNotEmpty || widget.proyect != null){
      //if(members.isNotEmpty){
        Map jsonBody = {};
        if(widget.proyect == null){
          jsonBody['name'] = controlleNewName.text;
        }

        members.add(myUser.id);

        for(int x = 0; x < members.length; x++){
          jsonBody['users[$x]'] = '${members[x]}';
        }

        try{
          if(widget.proyect == null){
            //******************************
            //*************NUEVO************
            //******************************
            var response = await connectionHttp.httpCreateProyect(jsonBody);
            var value = jsonDecode(response.body);
            if(value['status_code'] == 201){
              controlleNewName.text = '';
              checkUser = {};
              setState(() {});
              Navigator.of(context).pop(true);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) => new AddProyectsSumit(widget.blocPage)));
            }else{
              showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
            }
          }else{
            //******************************
            //**********AGREGAR*************
            //******************************
            var response = await connectionHttp.httpAddUserToProject(jsonBody,widget.proyect.id);
            var value = jsonDecode(response.body);
            if(value['status_code'] == 200){
              controlleNewName.text = '';
              checkUser = {};
              setState(() {});
              Navigator.of(context).pop(true);
            }else{
              showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
            }
          }
        }catch(e){
          print(e.toString());
          showAlert(translate(context: context, text: 'connectionError'),WalkieTaskColors.color_E07676);
        }
    }else{
      showAlert(translate(context: context, text: 'youMustNameProject'),WalkieTaskColors.color_E07676);
    }
    setState(() {
      cargando = false;
    });
  }
}
