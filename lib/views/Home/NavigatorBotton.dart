import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/Permisos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteCasos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteInvitation.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/avatar_widget.dart';
import 'package:walkietaskv2/utils/upload_background_documents.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/ListadoTareasRecibidas.dart';
import 'package:walkietaskv2/views/Tareas/ListadoTareasEnviadas.dart';
import 'package:walkietaskv2/views/Tareas/EnviarTarea.dart';
import 'package:walkietaskv2/views/Tareas/contact/contact.dart';
import 'package:walkietaskv2/views/Tareas/proyects/MyProyects.dart';
import '../../App.dart';

enum bottonSelect {opcion1,opcion2,opcion3,opcion4,opcion5}

class NavigatorBottonPage extends StatefulWidget {
  @override
  _NavigatorBottonPageState createState() => _NavigatorBottonPageState();
}

class _NavigatorBottonPageState extends State<NavigatorBottonPage> {

  double alto = 0;
  double ancho = 0;
  String titulo = 'Enviar tarea';
  conexionHttp conexionHispanos = new conexionHttp();
  bool cargadoUsuarios = false;
  Usuario myUser;

  bottonSelect page = bottonSelect.opcion1;

  Map<bottonSelect,bool> mapNavigatorBotton = new Map<bottonSelect,bool>();

  List<Tarea> listRecibidos;
  List<Tarea> listEnviados;
  Map<int,Usuario> mapIdUser;
  List<Usuario> listaUser;
  List<Caso> listaCasos;
  List<InvitationModel> listInvitation;

  BlocUser blocUser;
  BlocTask blocTaskSend;
  BlocTask blocTaskReceived;
  BlocCasos blocCasos;
  BlocCasos blocEmpresa;
  BlocCasos blocInvitation;
  BlocProgress blocIndicatorProgress;
  BlocPage blocPage;

  UpdateData updateData = new UpdateData();

  StreamSubscription streamSubscriptionUser;
  StreamSubscription streamSubscriptionTaskSend;
  StreamSubscription streamSubscriptionTaskRecived;
  StreamSubscription streamSubscriptionCasos;
  StreamSubscription streamSubscriptionInvitation;
  StreamSubscription streamSubscriptionProgress;
  StreamSubscription streamSubscriptionPage;

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool viewIndicatorProgress = false;
  double progressIndicator = 0;
  bool loadTaskSend = false;
  bool loadTaskRecived = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    buscarMyUser();

    blocUser = new BlocUser();
    blocTaskSend = new BlocTask();
    blocTaskReceived = new BlocTask();
    blocCasos = new BlocCasos();
    blocEmpresa = new BlocCasos();
    blocInvitation = new BlocCasos();
    blocIndicatorProgress = new BlocProgress();
    blocPage = BlocPage();

    listRecibidos = new List<Tarea>();
    listEnviados = new List<Tarea>();
    mapIdUser = new Map();
    listaUser = new List<Usuario>();
    listaCasos = new List<Caso>();
    listInvitation = new List<InvitationModel>();

    _inicializarPatronBlocUser();
    _inicializarPatronBlocTaskRecived();
    _inicializarPatronBlocTaskSend();
    _inicializarPatronBlocInvitation();
    _inicializarPatronBlocCasos();
    _inicializarPatronBlocProgress();
    _inicializarPatronBlocPage();

    _inicializarUser();
    _inicializarTaskRecived();
    _inicializarTaskSend();
    _inicializarCasos();
    _inicializarInvitation();

    updateData.actualizarListaUsuarios(blocUser);
    updateData.actualizarListaRecibidos(blocTaskReceived);
    updateData.actualizarListaEnviados(blocTaskSend);
    updateData.actualizarCasos(blocCasos);
    updateData.actualizarListaInvitationSent(blocInvitation);
    updateData.actualizarListaInvitationReceived(blocInvitation);

    mapNavigatorBotton[bottonSelect.opcion1] = true;
    mapNavigatorBotton[bottonSelect.opcion2] = false;
    mapNavigatorBotton[bottonSelect.opcion3] = false;
    mapNavigatorBotton[bottonSelect.opcion4] = false;
    mapNavigatorBotton[bottonSelect.opcion5] = false;

    verificarPermisos();
    uploadData();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionUser?.cancel();
    streamSubscriptionTaskSend?.cancel();
    streamSubscriptionTaskRecived?.cancel();
    streamSubscriptionCasos?.cancel();
    streamSubscriptionInvitation?.cancel();
    streamSubscriptionProgress?.cancel();
    streamSubscriptionPage?.cancel();
    blocUser.dispose();
    blocTaskSend.dispose();
    blocTaskReceived.dispose();
    blocCasos.dispose();
    blocInvitation.dispose();
    blocEmpresa.dispose();
    blocIndicatorProgress.dispose();
    blocPage.dispose();
  }

  List<dynamic> listDocuments= [];
  void uploadData() async {
    uploadBackDocuments(blocIndicatorProgress);
  }

  verificarPermisos()async{
    String token = await obtenerToken();
    print('****************');
    print('****************');
    print('$token');
    print('****************');
    print('****************');
    await PermisoStore();
    await PermisoSonido();
    await PermisoPhotos();
  }

  SharedPreferences prefs;
  buscarMyUser() async {
    prefs = await SharedPreferences.getInstance();
    String idMyUser = prefs.getString('unityIdMyUser');
    bool listo = true;
    while(listo){
      myUser = await UserDatabaseProvider.db.getCodeId(idMyUser);
      if(myUser != null){
        listo = false;
      }else{
        await Future.delayed(Duration(seconds: 3));
      }
    }
    setState(() {});
  }

  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: exit,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _drawerMenu(),
        appBar: AppBar(
          title: Container(
            width: ancho,
            child: Text('$titulo',
              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696),textAlign: TextAlign.right,),
          ),
          elevation: 0,
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            icon: Icon(Icons.menu,color: Colors.grey,size: 35,),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          bottom: _indicatorProgress(),
        ),
        // body: SafeArea(
        //   child: Container(
        //     width: ancho,
        //     height: double.infinity,
        //     color: Colors.white,
        //     child: SingleChildScrollView(
        //       child: Column(
        //         children: [
        //           _indicatorProgress(),
        //           Container(
        //             width: ancho,
        //             height: alto > 600 ? alto * 0.08 : alto * 0.09,
        //             child: Row(
        //               children: [
        //                 InkWell(
        //                   child: Icon(Icons.menu,color: Colors.grey,size: 35,),
        //                   onTap: (){
        //                     _scaffoldKey.currentState.openDrawer();
        //                   },
        //                 ),
        //                 Expanded(
        //
        //                 ),
        //               ],
        //             ),
        //           ),
        //           contenido(),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        body: Container(child: contenido(),),
        bottomNavigationBar: navigatorBotton(),
      ),
    );
  }

  Widget contenido(){
    switch(page){
      case bottonSelect.opcion1:
        return EnviarTarea(blocUserRes: blocUser,listUserRes: listaUser,
          myUserRes: myUser,listaCasosRes: listaCasos,
          blocTaskReceived: blocTaskReceived,blocTaskSend: blocTaskSend,
          blocIndicatorProgress: blocIndicatorProgress,);
      case bottonSelect.opcion2:
        return loadTaskSend ? listRecibidos.length != 0 ?
        ListadoTareasRecibidas(mapIdUserRes: mapIdUser,listRecibidos: listRecibidos,blocTaskReceivedRes: blocTaskReceived,listaCasosRes: listaCasos,myUserRes: myUser,) :
        Center(child: Text('No existen tareas recibidas',style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),),) :
        Container(child: Cargando('Buscando tareas recibidas',context),) ;
      case bottonSelect.opcion3:
        return loadTaskRecived ?
        listEnviados.length != 0 ?
        ListadoTareasEnviadas(listEnviadosRes: listEnviados,mapIdUserRes: mapIdUser,
          blocTaskSendRes: blocTaskSend,listaCasosRes: listaCasos,myUserRes: myUser,) :
        Center(child: Text('No existen tareas enviadas',style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),),) :
        Container(child: Cargando('Buscando tareas enviadas',context),);
      case bottonSelect.opcion4:
        return MyProyects(myUserRes: myUser, listUserRes: listaUser,
          blocPage: blocPage,listaCasosRes: listaCasos,blocCasos: blocCasos,);
      case bottonSelect.opcion5:
        return Contacts(myUserRes: myUser,mapIdUsersRes: mapIdUser,
          listInvitation: listInvitation,blocInvitation: blocInvitation,blocUser: blocUser,);
    }
    return Container();
  }
  Widget navigatorBotton(){
    return Container(
      height: alto * 0.08,
      child: Row(
        children: <Widget>[
          Expanded(
            child: navigatorBottonContenido(bottonSelect.opcion1,'','Enviar tarea','Tarea'),
          ),
          Expanded(
            child: navigatorBottonContenido(bottonSelect.opcion2,'-1','Tareas recibidas', 'Recibidas'),
          ),
          Expanded(
            child: navigatorBottonContenido(bottonSelect.opcion3,'-3','Tareas enviadas', 'Enviadas'),
          ),
          Expanded(
            child: navigatorBottonContenido(bottonSelect.opcion4,'-4','Proyectos', 'Proyectos'),
          ),
          Expanded(
            child: navigatorBottonContenido(bottonSelect.opcion5,'-5','Contactos', 'Contactos'),
          ),
        ],
      ),
    );
  }
  Widget navigatorBottonContenido(bottonSelect index,String num,String tit, subTitle){
    return InkWell(
      child: Container(
        color: mapNavigatorBotton[index] ? Colors.white : Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ancho,
                height: alto * 0.035,
                child: Image.asset(
                  'assets/image/Attachment$num.png',
                  color: !mapNavigatorBotton[index] ? null : WalkieTaskColors.primary,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Text(subTitle, style: WalkieTaskStyles().styleNunitoBold(size: alto * 0.016,color: !mapNavigatorBotton[index] ? WalkieTaskColors.color_ACACAC : WalkieTaskColors.primary),)
            ],
          ),
        ),
      ),
      onTap: (){
        if(!mapNavigatorBotton[index]){
          mapNavigatorBotton[index] = true;
          Map<bottonSelect,bool> auxMap = mapNavigatorBotton;
          auxMap.forEach((key,value){
            if(key != index){mapNavigatorBotton[key] = false;}
          });
        }
        titulo = tit;
        page = index;

        if(page == bottonSelect.opcion1){
          updateData.actualizarListaUsuarios(blocUser);
          updateData.actualizarCasos(blocCasos);
        }
        if(page == bottonSelect.opcion2){
          updateData.actualizarListaUsuarios(blocUser);
          updateData.actualizarListaRecibidos(blocTaskReceived);
          updateData.actualizarCasos(blocCasos);
        }
        if(page == bottonSelect.opcion3){
          updateData.actualizarListaUsuarios(blocUser);
          updateData.actualizarListaEnviados(blocTaskSend);
          updateData.actualizarCasos(blocCasos);
        }
        if(page == bottonSelect.opcion4){
          updateData.actualizarListaUsuarios(blocUser);
          updateData.actualizarCasos(blocCasos);
        }
        if(page == bottonSelect.opcion5){
          updateData.actualizarListaUsuarios(blocUser);
          updateData.actualizarListaInvitationSent(blocInvitation);
          updateData.actualizarListaInvitationReceived(blocInvitation);
        }

        setState(() {});
      },
    );
  }

  Widget _drawerMenu(){

    Image avatarUser = Image.network(avatarImage);
    if(myUser != null){
      if(myUser.avatar != null && myUser.avatar != ''){
        avatarUser = Image.network('$directorioImage${myUser.avatar}');
      }
    }

    Widget _divider = Container(height: 0.5, color: WalkieTaskColors.white, width: ancho,
      margin: EdgeInsets.only(bottom: alto * 0.02, top: alto * 0.02,),);

    return Drawer(
      elevation: 20.0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: WalkieTaskColors.color_4EA0F0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: ancho,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: alto * 0.025),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: ()=>Navigator.of(context).pop(),
                        child: Container(
                          width: ancho * 0.09,
                          height: alto * 0.06,
                          child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: WalkieTaskColors.white,),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: ancho,
                    margin: EdgeInsets.only(top: alto * 0.05, left: ancho * 0.05),
                    child: Row(
                      children: <Widget>[
                        avatarCirculeImage(WalkieTaskColors.grey,avatarUser,ancho * 0.1),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.05),
                            child: Text(myUser == null ? '' : myUser.name, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.white),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: alto * 0.02,),
            _divider,
            _textDrawer('Contactos', (){}),
            _divider,
            _textDrawer('Proyectos', (){}),
            _divider,
            _textDrawer('Mi Cuenta', (){}),
            _divider,
            _textDrawer('Acerca de', (){}),
            _divider,
            _textDrawer('Salir', () async {
              bool res = false;
              res = await alert(context);
              if(res != null && res){
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('unityToken');
                await prefs.remove('unityTokenExp');
                await prefs.remove('unityLogin');
                await prefs.remove('unityIdMyUser');
                await prefs.remove('WalListDocument');
                await prefs.remove('unityEmail');
                updateData.resetDB();
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new App()));
              }
            }),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(bottom: alto * 0.05),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: CircleAvatar(
                      radius: alto * 0.1,
                      backgroundColor: WalkieTaskColors.white,
                      child: Center(
                        child: Container(
                          width: ancho * 0.25,
                          height: alto * 0.08,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ViewImage().assetsImage("assets/image/LogoWN.png").image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _textDrawer(String text, Function onTap){
    return InkWell(
      onTap: (){
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        width: ancho,
        margin: EdgeInsets.only(left: ancho * 0.12, right: ancho * 0.02),
        child: Text(text, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.025, color: WalkieTaskColors.white),),
      ),
    );
  }

  int cant = 0;
  Widget _indicatorProgress(){

    String textCant = 'Enviando tarea...';
    if(cant > 1){
      textCant = 'Enviando tareas($cant)...';
    }

    return viewIndicatorProgress ? PreferredSize(
      preferredSize: Size.fromHeight(alto * 0.05),
      child: Container(
        color: colorfondoSelectUser,
        height: alto * 0.05,
        width: ancho,
        padding: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05),
        child: Row(
          children: <Widget>[
            Container(
              child: Text(textCant, style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.021, color: WalkieTaskColors.color_969696),),
            ),
            Expanded(
              child: Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  border: new Border.all(
                    width: 2,
                    color: WalkieTaskColors.primary,
                  ),
                ),
                child: LinearProgressIndicator(
                  backgroundColor: WalkieTaskColors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(WalkieTaskColors.primary),
                  value: progressIndicator,
                ),
              ),
            ),
          ],
        ),
      ),
    ) :
    PreferredSize(
      preferredSize: Size.fromHeight(0),
      child: Container()
    );
  }


  //*******************************************
  //*******************************************
  //*************DATOS LOCALES*****************
  //*******************************************
  //*******************************************

  _inicializarTaskRecived() async {
    listRecibidos = await TaskDatabaseProvider.db.getAllRecevid();
    loadTaskRecived = true;
    listEnviados = await TaskDatabaseProvider.db.getAllSend();
    loadTaskSend = true;
    setState(() {});
  }
  _inicializarTaskSend() async {
    listEnviados = await TaskDatabaseProvider.db.getAllSend();
    loadTaskSend = true;
    listRecibidos = await TaskDatabaseProvider.db.getAllRecevid();
    loadTaskRecived = true;
    setState(() {});
  }
  _inicializarUser() async {
    listaUser = await  UserDatabaseProvider.db.getAll();
    setState(() {});
    mapIdUser = new Map();
    for(int x = 0; x < listaUser.length; x++){
      mapIdUser[listaUser[x].id] = listaUser[x];
    }
    setState(() {});
  }
  _inicializarCasos() async {
    listaCasos = await  CasosDatabaseProvider.db.getAll();
    setState(() {});
  }
  _inicializarInvitation() async {
    listInvitation = await  InvitationDatabaseProvider.db.getAll();
    setState(() {});
  }
  //*******************************************
  //*******************************************
  //*************ESCUCHAR APIS*****************
  //*******************************************
  //*******************************************
  _inicializarPatronBlocUser(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionUser = blocUser.outList.listen((newVal) {
        if(newVal){
          _inicializarUser();
        }
      });
    } catch (e) {}
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
  _inicializarPatronBlocInvitation(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionInvitation = blocInvitation.outList.listen((newVal) {
        print('');
        if(newVal){
          _inicializarInvitation();
        }
      });
    } catch (e) {}
  }
  _inicializarPatronBlocTaskSend(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskSend = blocTaskSend.outList.listen((newVal) {
        if(newVal){
          _inicializarTaskSend();
        }
      });
    } catch (e) {}
  }
  _inicializarPatronBlocTaskRecived(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionTaskRecived = blocTaskReceived.outList.listen((newVal) {
        if(newVal){
          _inicializarTaskRecived();
        }
      });
    } catch (e) {}
  }
  _inicializarPatronBlocProgress(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionProgress = blocIndicatorProgress.outList.listen((newVal) {
        progressIndicator = double.parse('${newVal['progressIndicator']}');
        cant = int.parse('${newVal['cant']}');
        viewIndicatorProgress = newVal['viewIndicatorProgress'];
        setState(() {});
      });
    } catch (e) {}
  }
  _inicializarPatronBlocPage(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionPage = blocPage.outList.listen((newVal) {
        Map<int,bottonSelect> mapNewValue = {
          1 : bottonSelect.opcion1,
          2 : bottonSelect.opcion2,
          3 : bottonSelect.opcion3,
          4 : bottonSelect.opcion4,
          5 : bottonSelect.opcion5
        };
        mapNavigatorBotton[bottonSelect.opcion1] = false;
        mapNavigatorBotton[bottonSelect.opcion2] = false;
        mapNavigatorBotton[bottonSelect.opcion3] = false;
        mapNavigatorBotton[bottonSelect.opcion4] = false;
        mapNavigatorBotton[bottonSelect.opcion5] = false;
        mapNavigatorBotton[mapNewValue[newVal]] = true;
        page = mapNewValue[newVal];
        setState(() {});
      });
    } catch (e) {}
  }
}
