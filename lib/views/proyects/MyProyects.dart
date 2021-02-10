import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/proyects/add_proyects.dart';


class MyProyects extends StatefulWidget {

  MyProyects({this.myUserRes, this.listUserRes, this.blocPage, this.listaCasosRes, this.blocCasos});

  final Usuario myUserRes;
  final List<Usuario> listUserRes;
  final List<Caso> listaCasosRes;
  final BlocPage blocPage;
  final BlocCasos blocCasos;

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
  Map<int,bool> deleteProject = {};
  Map<String,bool> deleteProjectUser = {};

  TextStyle textStylePrimary;
  TextEditingController controlleBuscador;

  conexionHttp connectionHttp = new conexionHttp();

  BlocCasos blocCasos;
  StreamSubscription streamSubscriptionCasos;
  UpdateData updateData = new UpdateData();

  @override
  void initState() {
    super.initState();
    controlleBuscador = TextEditingController();
    myUser = widget.myUserRes;
    listUser = widget.listUserRes;
    listaCasos = widget.listaCasosRes ?? [];

    listaCasos.forEach((element) {
      openProjectView[element.id] = false;
      deleteProject[element.id] = false;
    });

    _getGuests();

    blocCasos = widget.blocCasos;
    _inicializarPatronBlocCasos();
  }

  @override
  void dispose() {
    super.dispose();
    try{
      streamSubscriptionCasos?.cancel();
    }catch(_){}
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
                  onTap: () async {
                    bool res = await Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new AddProyects(myUserRes: myUser, listUserRes: listUser,blocPage: widget.blocPage,proyect: null,listUsersExist: null,)));
                    if(res){
                      await updateData.actualizarCasos(blocCasos);
                      await _getGuests();
                    }
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
                  padding: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(project.name,
                          style: WalkieTaskStyles().stylePrimary(size: alto * 0.023),),
                      ),
                      InkWell(
                        child: Container(
                          child: !openProjectView[project.id] ?
                          Container(
                            width: ancho * 0.10,
                            height: alto * 0.05,
                            child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
                          ) :
                          Container(
                            width: ancho * 0.10,
                            height: alto * 0.05,
                            child: Image.asset('assets/image/icon_open_option.png',fit: BoxFit.fill,color: Colors.grey,),
                          ),
                        ),
                        onTap: (){
                          bool value = !openProjectView[project.id];
                          Map<int,bool> open = openProjectView;
                          open.forEach((key, value) {
                            openProjectView[key] = false;
                          });
                          openProjectView[project.id] = value;
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
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.04, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                        backgroundColor: WalkieTaskColors.primary,
                        onPressed: () async {
                          bool res = await Navigator.push(context, new MaterialPageRoute(
                              builder: (BuildContext context) =>
                              new AddProyects(
                                myUserRes: myUser,
                                listUserRes: listUser,
                                blocPage: widget.blocPage,
                                proyect: project,
                                listUsersExist: projectsUser[project.id] ?? [],
                              )));
                          if(res){
                            await _getGuests();
                          }
                        },
                      ),
                      SizedBox(width: ancho * 0.1,),
                      deleteProject[project.id] ?
                      Container(
                        width: ancho * 0.4,
                        child: Center(
                          child: Container(
                            width: ancho * 0.06,
                            height: alto * 0.03,
                            child: Center(child: CircularProgressIndicator(),),
                          ),
                        ),
                      ) :
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
                          onPressed: () async {
                            deleteProject[project.id] = true;
                            setState(() {});

                            bool res = false;
                            res = await alertDeleteProject(context, project.name);
                            if(res != null && res){
                              try{
                                var response = await connectionHttp.httpDeleteProject(project.id);
                                var value = jsonDecode(response.body);
                                if(value['status_code'] == 200){
                                  int res = await DatabaseProvider.db.deleteProjectCase(project.id);
                                  if(res != 0){
                                    await _inicializarCasos();
                                    showAlert('Proyecto eliminado.',WalkieTaskColors.color_89BD7D);
                                  }
                                }else{
                                  showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                                }
                              }catch(e){
                                print(e.toString());
                                showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                              }
                            }
                            deleteProject[project.id] = false;
                            setState(() {});
                          },
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
        result.add(SizedBox(height: alto * 0.01,));
        result.add(Divider(thickness: 0.8,));
      }
    });
    return result;
  }

  List<Widget> _cardUsers(int idProjects){
    List<Widget> users = [];
    List listUsers = projectsUser[idProjects] ?? [];
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
                        Text('$name',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02),maxLines: 1,),
                        Text(email,style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, spacing: 1),maxLines: 1,)
                      ],
                    ),
                  ),
                ),
                deleteProjectUser['$idProjects-${mapUserProject['users']['id']}'] ?
                Container(
                  width: ancho * 0.06,
                  height: alto * 0.03,
                  child: Center(child: CircularProgressIndicator(),),
                ) :
                RoundedButton(
                  borderColor: WalkieTaskColors.color_E07676,
                  width: ancho * 0.18,
                  height: alto * 0.03,
                  radius: 5.0,
                  title: 'Eliminar',
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: ancho * 0.035, color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1.5),
                  backgroundColor: WalkieTaskColors.color_E07676,
                  onPressed: () async {
                    deleteProjectUser['$idProjects-${mapUserProject['users']['id']}'] = true;
                    setState(() {});
                    try{
                      var response = await connectionHttp.httpDeleteUserForProject(idProjects,mapUserProject['users']['id']);
                      var value = jsonDecode(response.body);
                      if(value['status_code'] == 200){
                        await _getGuests();
                        showAlert('Usuario eliminado del proyecto con exito.!',WalkieTaskColors.color_89BD7D);
                      }else{
                        showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                      }
                    }catch(e){
                      print(e.toString());
                      showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                    }

                    deleteProjectUser['$idProjects-${mapUserProject['users']['id']}'] = false;
                    setState(() {});
                  },
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
    // setState(() {
    //   loadGuests = true;
    // });
    try{
      var response = await connectionHttp.httpGetListGuestsForProjects();
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        if(value['projects'] != null){
          List listHttp = value['projects'];
          listHttp.forEach((element) {
            projectsUser[element['id']] = element['userprojects'];
            List users = element['userprojects'];
            users.forEach((user) {
              if(user['users']['id'] != myUser.id){
                deleteProjectUser['${element['id']}-${user['users']['id']}'] = false;
              }
            });
          });
        }
      }
    }catch(e){
      print(e.toString());
    }
    if (this.mounted) {
      setState(() {
        loadGuests = false;
      });
    }
  }

  _inicializarPatronBlocCasos(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionCasos = blocCasos.outList.listen((newVal) {
        if(newVal){
          _inicializarCasos();
        }
      });
    } catch (e) {}
  }

  _inicializarCasos() async {
    listaCasos = await  DatabaseProvider.db.getAllCase() ?? [];
    listaCasos.forEach((element) {
      openProjectView[element.id] = false;
      deleteProject[element.id] = false;
    });
    setState(() {});
  }
}
