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
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/proyects/add_proyects.dart';


class MyProyects extends StatefulWidget {

  MyProyects(this.myUserRes, this.listUserRes, this.blocPage, this.listaCasosRes);

  final Usuario myUserRes;
  final List<Usuario> listUserRes;
  final List<Caso> listaCasosRes;
  final BlocPage blocPage;

  @override
  _MyProyectsState createState() => _MyProyectsState();
}

class _MyProyectsState extends State<MyProyects> {

  Usuario myUser;
  double alto = 0;
  double ancho = 0;
  bool cargando = false;
  bool loadGuests = true;

  List<Usuario> listUser;
  List<Caso> listaCasos;

  Map<int,bool> openProjectView = {};
  Map<int,List> projectsUser = {};

  TextStyle textStylePrimary;
  TextEditingController controlleBuscador;

  conexionHttp connectionHttp = new conexionHttp();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controlleBuscador = TextEditingController();
    myUser = widget.myUserRes;
    listUser = widget.listUserRes;
    listaCasos = widget.listaCasosRes ?? [];

    listaCasos.forEach((element) {
      openProjectView[element.id] = false;
    });

    _getGuests();
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
            ),
            _listProjects(),
          ],
        ),
      ),
    );
  }

  Widget _listProjects(){

    List<Widget> cards = _cardS();

    return Container(
      width: ancho,
      child: SingleChildScrollView(
        child: Column(
          children: cards,
        ),
      ),
    );
  }

  List<Widget> _cardS(){
    List<Widget> result = [];

    listaCasos.forEach((project) {
      if(myUser.id == project.user_id){

        List<Widget> listChildrem = loadGuests ? [
          Container(width: ancho,child: Center(child: CircularProgressIndicator(),),margin: EdgeInsets.only(top: alto * 0.03, bottom: alto * 0.03),)
        ] : _cardUsers(project.id);

        result.add(
          Container(
            width: ancho,
            child: Column(
              children: <Widget>[
                Container(
                  width: ancho,
                  padding: EdgeInsets.only(left: ancho * 0.05),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(project.name, style: WalkieTaskStyles().stylePrimary(size: alto * 0.025),),
                      ),
                      InkWell(
                        child: Container(
                          child: !openProjectView[project.id] ?
                          Container(
                            width: ancho * 0.12,
                            height: alto * 0.06,
                            child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
                          ) :
                          Container(
                            width: ancho * 0.12,
                            height: alto * 0.06,
                            child: Image.asset('assets/image/icon_open_option.png',fit: BoxFit.fill,color: Colors.grey,),
                          ),
                        ),
                        onTap: (){
                          openProjectView[project.id] = !openProjectView[project.id];
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                !openProjectView[project.id] ? Container() :
                Container(
                  width: ancho,
                  child: Column(
                    children: listChildrem,
                  ),
                ),
                !openProjectView[project.id] ? Container() :
                Container(
                  width: ancho,
                  margin: EdgeInsets.only(left: ancho * 0.1),
                  child: Row(
                    children: <Widget>[
                      RoundedButton(
                        borderColor: WalkieTaskColors.primary,
                        width: ancho * 0.2,
                        height: alto * 0.04,
                        radius: 5.0,
                        title: 'Agregar',
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 2),
                        backgroundColor: WalkieTaskColors.primary,
                        onPressed: (){},
                      ),
                      SizedBox(width: ancho * 0.1,),
                      Expanded(
                        child: RoundedButton(
                          borderColor: WalkieTaskColors.white,
                          width: ancho * 0.2,
                          height: alto * 0.04,
                          radius: 5.0,
                          title: 'Eliminar "${project.name}"',
                          textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.03, color: WalkieTaskColors.color_E07676,fontWeight: FontWeight.bold,spacing: 2),
                          backgroundColor: WalkieTaskColors.white,
                          maxLines: 1,
                          onPressed: (){},
                        ),
                      ),
                      SizedBox(width: ancho * 0.05,),
                    ],
                  ),
                ),
              ],
            ),
          )
        );
        result.add(Divider());
      }
    });
    return result;
  }

  List<Widget> _cardUsers(int idProjects){
    List<Widget> users = [];
    List listUsers = projectsUser[idProjects];
    listUsers.forEach((mapUserProject) {
      if(mapUserProject['users']['id'] != myUser.id){
        String avatar = mapUserProject['users']['avatar'];
        String name = mapUserProject['users']['name'];
        String email = mapUserProject['users']['email'];

        Image avatarUser = Image.network(avatarImage);
        if(avatar != null){
          avatarUser = Image.network('$directorioImage$avatar');
        }

        users.add(
          Container(
            width: ancho,
            margin: EdgeInsets.only(bottom: alto * 0.015, left: ancho * 0.05, right: ancho * 0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: ancho * 0.02),
                  padding: const EdgeInsets.all(3.0), // borde width
                  decoration: new BoxDecoration(
                    color: bordeCirculeAvatar, // border color
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: alto * 0.025,
                    backgroundImage: avatarUser.image,
                    //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name,style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018),maxLines: 1,),
                        Text(email,style: WalkieTaskStyles().stylePrimary(size: alto * 0.016, spacing: 1),maxLines: 1,)
                      ],
                    ),
                  ),
                ),
                RoundedButton(
                  borderColor: WalkieTaskColors.color_E07676,
                  width: ancho * 0.18,
                  height: alto * 0.03,
                  radius: 5.0,
                  title: 'Eliminar',
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.035, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 2),
                  backgroundColor: WalkieTaskColors.color_E07676,
                  onPressed: (){},
                ),
              ],
            ),
          )
        );
      }
    });
    return users;
  }

  Future<void> _getGuests() async {
    try{
      var response = await connectionHttp.httpGetListGuestsForProjects();
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        if(value['projects'] != null){
          List listHttp = value['projects'];
          listHttp.forEach((element) {
            projectsUser[element['id']] = element['userprojects'];
          });
        }
      }
    }catch(e){
      print(e.toString());
    }
    setState(() {
      loadGuests = false;
    });
  }
}
