import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:walkietaskv2/App.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocPage.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Permisos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Sqlite/sqlite_instance.dart';
import 'package:walkietaskv2/services/upload_background_documents.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/avatar_widget.dart';
import 'package:walkietaskv2/utils/flushbar_notification.dart';
import 'package:walkietaskv2/utils/order_tasks.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/finish_app.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Home/about.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/Tareas/Create/crear_tarea.dart';
import 'package:walkietaskv2/views/Tareas/ListadoTareasRecibidas.dart';
import 'package:walkietaskv2/views/Tareas/ListadoTareasEnviadas.dart';
import 'package:walkietaskv2/views/contact/contact.dart';
import 'package:walkietaskv2/views/profile/profile_home.dart';
import 'package:walkietaskv2/views/proyects/MyProyects.dart';
import 'package:walkietaskv2/views/binnacle/binnacle.dart';

enum bottonSelect {opcion1,opcion2,opcion3,opcion4,opcion5}

class NavigatorBottonPage extends StatefulWidget {
  @override
  _NavigatorBottonPageState createState() => _NavigatorBottonPageState();
}

class _NavigatorBottonPageState extends State<NavigatorBottonPage> {

  Usuario myUser;

  String titulo = '';

  double alto = 0;
  double ancho = 0;
  double progressIndicator = 0;
  int posVery = 0;

  Map<bottonSelect,bool> mapNavigatorBotton = new Map<bottonSelect,bool>();
  Map<int,Usuario> mapIdUser;
  Map<int,List> mapDataUserHome = {};

  List<Tarea> listRecibidos;
  List<Tarea> listEnviados;
  List<Usuario> listaUser;
  List<Caso> listaCasos;
  List<InvitationModel> listInvitation;
  List<Map<String,dynamic>> listNotifications;
  List<dynamic> listDocuments= [];

  BlocUser blocUser;
  BlocTask blocTaskSend;
  BlocTask blocTaskReceived;
  BlocCasos blocCasos;
  BlocCasos blocInvitation;
  BlocProgress blocIndicatorProgress;
  BlocPage blocPage;
  BlocCasos blocConection;
  BlocProgress blocAudioChangePage = new BlocProgress();
  BlocPage blocVerifyFirst = BlocPage();

  UpdateData updateData = new UpdateData();

  StreamSubscription streamSubscriptionUser;
  StreamSubscription streamSubscriptionTaskSend;
  StreamSubscription streamSubscriptionTaskRecived;
  StreamSubscription streamSubscriptionCasos;
  StreamSubscription streamSubscriptionInvitation;
  StreamSubscription streamSubscriptionConection;
  StreamSubscription streamSubscriptionProgress;
  StreamSubscription streamSubscriptionPage;
  StreamSubscription streamSubscriptionVerify;

  bool viewIndicatorProgress = false;
  bool cargadoUsuarios = false;
  bool conectionActive = false;
  bool loadTaskSend = false;
  bool loadTaskRecived = false;
  bool loadListUser = false;
  bool loadCasos = false;
  bool loadMyUser = false;
  bool notiRecived = false;
  bool notiSend = false;
  bool notiContacts = false;

  conexionHttp conexionHispanos = new conexionHttp();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bottonSelect page = bottonSelect.opcion1;
  BuildContext contextHome;

  Image avatarUser;

  @override
  void initState() {
    super.initState();

    buscarMyUser();

    blocUser = new BlocUser();
    blocTaskSend = new BlocTask();
    blocTaskReceived = new BlocTask();
    blocCasos = new BlocCasos();
    blocConection = new BlocCasos();
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
    _inicializarPatronBlocConection();
    _inicializarPatronBlocVerify();

    _inicializarUser();
    _inicializarTaskRecived();
    _inicializarTaskSend();
    _inicializarCasos();
    _inicializarInvitation();
    _inicializarListNotification();

    updateData.actualizarListaUsuarios(blocUser, blocConection);
    updateData.actualizarListaRecibidos(blocTaskReceived, blocConection, blocVerifyFirst: blocVerifyFirst);
    updateData.actualizarListaEnviados(blocTaskSend, blocConection);
    updateData.actualizarCasos(blocCasos);
    updateData.actualizarListaInvitationSent(blocInvitation, blocConection);
    updateData.actualizarListaInvitationReceived(blocInvitation, blocConection, blocVerifyFirst: blocVerifyFirst);

    mapNavigatorBotton[bottonSelect.opcion1] = true;
    mapNavigatorBotton[bottonSelect.opcion2] = false;
    mapNavigatorBotton[bottonSelect.opcion3] = false;
    mapNavigatorBotton[bottonSelect.opcion4] = false;
    mapNavigatorBotton[bottonSelect.opcion5] = false;

    verificarPermisos();
    _notificationListener();

    uploadData();

    //Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();

    //Wakelock.disable();

    try{
      streamSubscriptionUser?.cancel();
      streamSubscriptionTaskSend?.cancel();
      streamSubscriptionTaskRecived?.cancel();
      streamSubscriptionCasos?.cancel();
      streamSubscriptionInvitation?.cancel();
      streamSubscriptionConection?.cancel();
      streamSubscriptionProgress?.cancel();
      streamSubscriptionPage?.cancel();
      streamSubscriptionVerify?.cancel();
      blocUser.dispose();
      blocTaskSend.dispose();
      blocTaskReceived.dispose();
      blocCasos.dispose();
      blocInvitation.dispose();
      blocConection.dispose();
      blocIndicatorProgress.dispose();
      blocPage.dispose();
      blocAudioChangePage?.dispose();
      blocVerifyFirst.dispose();
    }catch(e){
      print(e.toString());
    }
  }

  void uploadData() async {
    List<dynamic> listDocuments = await SharedPrefe().getValue('WalListDocument') ?? [];
    if(listDocuments.isNotEmpty){
      uploadBackDocuments(blocIndicatorProgress);
    }

    List<dynamic> listDocuments2 = await SharedPrefe().getValue('WalListUpdateAvatar') ?? [];
    if(listDocuments2.isNotEmpty){
      uploadUpdateUser();
    }
  }

  Future<void> reconection() async {
    try{
      if(conectionActive){
        bool conect = false;
        print('Esperando conexion');
        conect = await checkConectivity();
        print('Esperando conexion  = $conect');
        if(conect){
          updateData.actualizarListaUsuarios(blocUser, blocConection);
          updateData.actualizarCasos(blocCasos);
        }else{
          reconection();
        }
      }
    }catch(_){}
  }

  verificarPermisos()async{

    await SharedPrefe().setIntValue('openTask', 0);
    await SharedPrefe().setIntValue('popValueTask', 0);

    String token = await obtenerToken();
    print('******** TOKEN SERVER ********');
    print('******** TOKEN SERVER ********');
    print('$token');
    print('******** TOKEN SERVER ********');
    print('******** TOKEN SERVER ********');
    await PermisoStore();
    await PermisoSonido();
    await PermisoPhotos();
  }

  buscarMyUser() async {
    String idMyUser = await SharedPrefe().getValue('unityIdMyUser');
    bool listo = true;
    while(listo){
      myUser = await DatabaseProvider.db.getCodeIdUser(idMyUser);
      if(myUser != null){
        listo = false;
        loadMyUser = true;
      }else{
        await Future.delayed(Duration(seconds: 3));
      }
    }
    getPhoto();

    setState(() {});
  }

  Future<void> getPhoto() async {
    avatarUser = await getPhotoUser();
    setState(() {});
  }

  Future<bool> exit() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;
    contextHome = context;

    translateTitle(context);

    reconection();

    return WillPopScope(
      onWillPop: exit,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _drawerMenu(),
        appBar: AppBar(
          title: Container(
            padding: EdgeInsets.only(right: page == bottonSelect.opcion1 ? ancho * 0.1 : 0),
            width: ancho,
            child: Text('$titulo',
              style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696),textAlign: page == bottonSelect.opcion1 ? TextAlign.center : TextAlign.right,),
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
        body: Container(child: contenido(),),
        bottomNavigationBar: navigatorBotton(),
      ),
    );
  }

  void translateTitle(BuildContext context){
    switch (page) {
      case bottonSelect.opcion1:
        titulo = translate(context: context, text: 'tasks');
        break;
      case bottonSelect.opcion2:
        titulo = translate(context: context, text: 'receivedTasks');
        break;
      case bottonSelect.opcion3:
        titulo = translate(context: context, text: 'sentTasks');
        break;
      case bottonSelect.opcion4:
        titulo = translate(context: context, text: 'projects');
        break;
      case bottonSelect.opcion5:
        titulo = translate(context: context, text: 'contacts');
        break;
    }
    setState(() {});
  }

  Widget contenido(){
    switch(page){
      case bottonSelect.opcion1:

        if((loadTaskRecived && loadTaskSend)){
          mapDataUserHome = _dataToMapDataUserHome();
        }

        return (loadTaskRecived && loadTaskSend && loadListUser && loadCasos && loadMyUser) ?
        CreateTask(
          myUserRes: myUser,
          listUserRes: listaUser,
          mapIdUserRes: mapIdUser,
          listaCasosRes: listaCasos,
          listEnviadosRes: listEnviados,
          listRecibidos: listRecibidos,
          blocUserRes: blocUser,
          blocTaskReceived: blocTaskReceived,
          blocTaskSend: blocTaskSend,
          blocIndicatorProgress: blocIndicatorProgress,
          mapDataUserHome: mapDataUserHome,
          updateData: updateData,
          blocAudioChangePage: blocAudioChangePage,
        ) : Container(child: Cargando(translate(context: context,text: 'updatingTasks'),context),);
      case bottonSelect.opcion2:
        return loadTaskSend ? listRecibidos.length != 0 ?
        ListadoTareasRecibidas(
          mapIdUserRes: mapIdUser,
          listRecibidos: listRecibidos,
          blocTaskReceivedRes: blocTaskReceived,
          listaCasosRes: listaCasos,
          myUserRes: myUser,
          push: push,
          blocAudioChangePage: blocAudioChangePage,
        ) :
        Center(child: Text(translate(context: context,text: 'noReceivedTasks'),style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),),) :
        Container(child: Cargando(translate(context: context, text: 'searchingForReceivedTasks'),context),) ;
      case bottonSelect.opcion3:
        return loadTaskRecived ?
        listEnviados.length != 0 ?
        ListadoTareasEnviadas(
          listEnviadosRes: listEnviados,
          mapIdUserRes: mapIdUser,
          blocTaskSendRes: blocTaskSend,
          listaCasosRes: listaCasos,
          myUserRes: myUser,
          push: push,
          blocAudioChangePage: blocAudioChangePage,
        ) :
        Center(child: Text(translate(context: context,text: 'noSentTasks'),style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.025),),) :
        Container(child: Cargando(translate(context: context, text: 'searchingForSubmittedTasks'),context),);
      case bottonSelect.opcion4:
        return MyProyects(
          myUserRes: myUser,
          listUserRes: listaUser,
          blocPage: blocPage,
          listaCasosRes: listaCasos,
          blocCasos: blocCasos,
        );
      case bottonSelect.opcion5:
        return Contacts(
          myUserRes: myUser,
          mapIdUsersRes: mapIdUser,
          listInvitation: listInvitation,
          blocInvitation: blocInvitation,
          blocUser: blocUser,
          push: push,
        );
    }
    return Container();
  }
  Widget navigatorBotton(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: navigatorBottonContenido(bottonSelect.opcion1,'',translate(context: context,text: 'home'),false),
              ),
              Expanded(
                child: navigatorBottonContenido(bottonSelect.opcion2,'-1', translate(context: context,text: 'received'),notiRecived),
              ),
              Expanded(
                child: navigatorBottonContenido(bottonSelect.opcion3,'-3', translate(context: context,text: 'sent_2'),notiSend),
              ),
              Expanded(
                child: navigatorBottonContenido(bottonSelect.opcion4,'-4', translate(context: context,text: 'projects'),false),
              ),
              Expanded(
                child: navigatorBottonContenido(bottonSelect.opcion5,'-5', translate(context: context,text: 'contacts'),notiContacts),
              ),
            ],
          ),
        ),
        conectionActive ? Container(
          width: ancho,
          height: alto * 0.05,
          color: Colors.red[300],
          child: Center(child: Text('${translate(context: context,text: 'noConnectionReconnect')} . . . '),),
        ) : Container(),
      ],
    );
  }
  Widget navigatorBottonContenido(bottonSelect index,String num, subTitle, bool noti){
    return Stack(
      children: [
        InkWell(
          child: Container(
            padding: EdgeInsets.only(top: alto * 0.005, bottom: alto * 0.005),
            color: mapNavigatorBotton[index] ? Colors.white : Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: ancho,
                  height: alto * 0.035,
                  child: Image.asset('assets/image/Attachment$num.png',color: !mapNavigatorBotton[index] ? null : WalkieTaskColors.primary,fit: BoxFit.fitHeight,),
                ),
                Text(subTitle, style: WalkieTaskStyles().stylePrimary(size: alto * 0.016,color: !mapNavigatorBotton[index] ? WalkieTaskColors.color_ACACAC : WalkieTaskColors.primary, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          onTap: () async {
            _onTapNavigator(index);
          },
        ),
        noti ? Container(
          margin: EdgeInsets.only(top: alto * 0.005, right: ancho * 0.01),
          child: Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.circle, color: Colors.red,size: alto * 0.015,),
          ),
        ) : Container(),
      ],
    );
  }
  void _onTapNavigator(bottonSelect index){
    if(!mapNavigatorBotton[index]){
      mapNavigatorBotton[index] = true;
      Map<bottonSelect,bool> auxMap = mapNavigatorBotton;
      auxMap.forEach((key,value){
        if(key != index){mapNavigatorBotton[key] = false;}
      });
    }
    page = index;
    blocAudioChangePage.inList.add({'page' : index});

    updateData.actualizarCasos(blocCasos);
    updateData.actualizarListaUsuarios(blocUser, blocConection);

    if(page == bottonSelect.opcion1){
      updateData.actualizarListaRecibidos(blocTaskReceived, blocConection);
      updateData.actualizarListaEnviados(blocTaskSend, blocConection);
    }
    if(page == bottonSelect.opcion2){
      updateData.actualizarListaRecibidos(blocTaskReceived, blocConection);
      updateNoti(0, false);
    }
    if(page == bottonSelect.opcion3){
      updateData.actualizarListaEnviados(blocTaskSend, blocConection);
      updateNoti(3, false);
    }
    if(page == bottonSelect.opcion4){ }
    if(page == bottonSelect.opcion5){
      updateData.actualizarListaInvitationSent(blocInvitation, blocConection);
      updateData.actualizarListaInvitationReceived(blocInvitation, blocConection);
      updateNoti(1, false);
    }
    setState(() {});
  }

  Map<int,List> _dataToMapDataUserHome(){
    Map<int,List> data = {};
    try{
      listRecibidos.forEach((task) {
        if(data[task.user_id] == null){
          data[task.user_id] = ['',[],[]];
        }
        data[task.user_id][1].add(task);
        if(task.finalized == 0){
          if(data[task.user_id][0] == ''){
            data[task.user_id][0] = task.deadline;
          }else{
            if(task.deadline.isEmpty || data[task.user_id][0].isEmpty){
              if(data[task.user_id][0].isEmpty){ data[task.user_id][0] = task.deadline.isEmpty; }
            }else{
              DateTime dateCreate = DateTime.parse(task.deadline);
              Duration difDays = dateCreate.difference(DateTime.now());

              DateTime dateCreate2 = DateTime.parse(data[task.user_id][0]);
              Duration difDays2 = dateCreate2.difference(DateTime.now());

              if(difDays < difDays2){
                data[task.user_id][0] = dateCreate2.toString();
              }
            }
          }
        }
      });

      listEnviados.forEach((task) {
        if(data[task.user_responsability_id] == null){
          data[task.user_responsability_id] = ['',[],[]];
        }
        data[task.user_responsability_id][2].add(task);
        if(task.finalized == 0){
          if(data[task.user_responsability_id][0] == ''){
            data[task.user_responsability_id][0] = task.deadline;
          }else{
            if(task.deadline.isEmpty || data[task.user_responsability_id][0].isEmpty){
              if(data[task.user_responsability_id][0].isEmpty){ data[task.user_responsability_id][0] = task.deadline.isEmpty; }
            }else{
              DateTime dateCreate = DateTime.parse(task.deadline);
              Duration difDays = dateCreate.difference(DateTime.now());

              DateTime dateCreate2 = DateTime.parse(data[task.user_responsability_id][0]);
              Duration difDays2 = dateCreate2.difference(DateTime.now());

              if(difDays < difDays2){
                data[task.user_responsability_id][0] = dateCreate2.toString();
              }
            }
          }
        }
      });

      listaUser.forEach((user) {
        if(user.contact == 1){
          bool hereIam = false;
          data.forEach((key, value) {
            if(key == user.id){
              hereIam = true;
            }
          });
          if(!hereIam){
            data[user.id] = ['',[],[]];
          }
        }
      });

    }catch(e){
      print('ERROR AL ORDENAR DATA DE HOME');
    }
    return data;
  }

  Widget _drawerMenu(){

    avatarUser = avatarUser ?? Image.network(avatarImage);
    if(myUser != null){
      if(myUser.avatar_100 != null && myUser.avatar_100 != ''){
        avatarUser = Image.network(myUser.avatar_100);
      }
    }

    Widget _divider = Divider(color: WalkieTaskColors.white,);

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
            _textDrawer(translate(context: context, text: 'contacts'), (){
              _onTapNavigator(bottonSelect.opcion5);
            }),
            _divider,
            _textDrawer(translate(context: context, text: 'projects'), (){
              _onTapNavigator(bottonSelect.opcion4);
            }),
            _divider,
            _textDrawer(translate(context: context, text: 'myAccount'), () async {
              var res = await Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) => ProfileHome(
                    myUser: myUser,
                  )));

              if(res[0]){
                titulo = '';
                myUser = await updateData.getMyUser();
                await updateData.actualizarListaUsuarios(blocUser, blocConection);
                if(res[1]){
                  myUser.avatar_100 = '';
                  getPhoto();
                }
                setState(() {});
              }
            }),
            _divider,
            _textDrawer(translate(context: context, text: 'activity'), () async {
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) => BinnaclePage(
                    myUser: myUser,
                    blocTaskReceived: blocTaskReceived,
                    listCase: listaCasos,
                  )));
            }),
            _divider,
            _textDrawer(translate(context: context, text: 'about'), (){
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context) => Abbout()));
            }),
            _divider,
            _textDrawer(translate(context: context, text: 'logOut'), () async {
              bool res = false;
              res = await alert(context);
              if(res != null && res){
                await finishApp();
                Navigator.pushReplacement(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new App()));
              }
            }),
            Flexible(
              child: Container(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: CircleAvatar(
                      radius: alto * 0.1,
                      backgroundColor: WalkieTaskColors.white,
                      child: Center(
                        child: Container(
                          height: alto * 0.08,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ViewImage().assetsImage("assets/image/LogoWN.png").image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: ancho,
              margin: EdgeInsets.only(bottom: alto * 0.04,top: alto * 0.01),
              child: Text('V-$versionApp',textAlign: TextAlign.center,style: WalkieTaskStyles().styleNunitoBold(size: alto * 0.02, color: WalkieTaskColors.white),),
            ),
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
    List<Tarea> listR = await DatabaseProvider.db.getAllRecevidTask();
    listRecibidos = await OrderTask().orderListReceived(listR);
    loadTaskRecived = true;

    List<Tarea> listS = await DatabaseProvider.db.getAllSendTask();
    listEnviados = await OrderTask().orderListSend(listS);
    loadTaskSend = true;
    _inicializarUser();
    setState(() {});
  }
  _inicializarTaskSend() async {
    List<Tarea> listS = await DatabaseProvider.db.getAllSendTask();
    listEnviados = await OrderTask().orderListSend(listS);
    loadTaskSend = true;

    List<Tarea> listR = await DatabaseProvider.db.getAllRecevidTask();
    listRecibidos = await OrderTask().orderListReceived(listR);
    loadTaskRecived = true;
    _inicializarUser();
    setState(() {});
  }
  _inicializarUser() async {
    listaUser = await  DatabaseProvider.db.getAllUser();
    mapIdUser = new Map();
    for(int x = 0; x < listaUser.length; x++){
      mapIdUser[listaUser[x].id] = listaUser[x];
    }
    loadListUser = true;

    listaUser = orderUserForDate(listaUser);

    setState(() {});
  }
  _inicializarCasos() async {
    listaCasos = await  DatabaseProvider.db.getAllCase();
    loadCasos = true;
    setState(() {});
  }
  _inicializarInvitation() async {
    listInvitation = await  DatabaseProvider.db.getAllInvitation();
    setState(() {});
    validateInvitation(listInvitation);
  }
  _inicializarListNotification() async {
    getDataNotiForServer('0');
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
        }else{
          setState(() {});
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
        if(progressIndicator == 1.0){
          _inicializarTaskSend();
        }
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
  _inicializarPatronBlocConection(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionConection = blocConection.outList.listen((newVal) {
        setState(() {
          conectionActive = newVal;
        });
      });
    } catch (e) {}
  }
  _inicializarPatronBlocVerify(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionVerify = blocVerifyFirst.outList.listen((newVal) {
        posVery = posVery + newVal;
        if(posVery == 2){
          verifyNewTaskInvitation();
        }
        setState(() {});
      });
    } catch (e) {}
  }


  PushProvider push;
  void _notificationListener() async{
    push = new PushProvider();
    push.getToken();
    await push.initNotificaciones();
    push.mensajes.listen((argumento) async {
      try{
        int counter = await SharedPrefe().getValue('unityLogin');
        if(counter == 1){
          getDataNotiForServer(argumento['type']);
        }
      }catch(e){
        print(e.toString());
      }
      setState(() {});
    });
  }

  Future<void> getDataNotiForServer(String type) async{
    listNotifications = await  updateData.getNotifications();

    bool checkReceived = false;
    bool checkSend = false;
    bool checkContacts = false;
    for(int x = 0; x < listNotifications.length; x++){
      if(listNotifications[x]['type'] == 'tasks'){
        checkReceived = true;
      }
      if(checkReceived){
        x = listNotifications.length;
      }
    }

    if(type == '0'){
      if(checkReceived){
        updateNoti(0,true);
      }
    }
    if(type == '1'){

    }
    if(type == '2' || type == '3'){

    }

    setState(() {});


    /*
    if(argumento['table'] != null && (argumento['table'] == 'tasks' ||
        argumento['table'].contains('contacts'))) {
      bool isTask = argumento['table'].contains('tasks');
      if (isTask) {
        try{
          List<dynamic> listTaskNew = await SharedPrefe().getValue('notiListTask');
          if (listTaskNew == null) {
            listTaskNew = [];
          }
          List<String> listTaskNewString = [];
          listTaskNew.forEach((element) { listTaskNewString.add(element);});
          listTaskNewString.add(argumento['idDoc']);
          await SharedPrefe().setStringListValue('notiListTask', listTaskNewString);
        }catch(_){}
        updateData.actualizarListaRecibidos(blocTaskReceived, blocConection);
        updateData.actualizarListaEnviados(blocTaskSend, blocConection);
      }
    }

    if(argumento['table'] != null && argumento['table'].contains('contacts')){
      if (page != bottonSelect.opcion5) {
        updateNoti(1, true);
        updateNoti(2, true);
      }
      if (page == bottonSelect.opcion5) {
        updateNoti(2, true);
      }
    }

    if(argumento['table'] != null && argumento['table'].contains('sms')){
      if(argumento['idDoc'] != null){
        Tarea task = await DatabaseProvider.db.getCodeIdTask(argumento['idDoc']);
        task.updated_at = DateTime.now().toString();
        await DatabaseProvider.db.updateTask(task);
        bool isSend = task.user_id == myUser.id;

        if(argumento['type'] == '1'){
          List<dynamic> listTaskNew = await SharedPrefe().getValue('notiListChat');
          if (listTaskNew == null) {
            listTaskNew = [];
          }
          List<String> listTaskNewString = [];
          listTaskNew.forEach((element) { listTaskNewString.add(element);});
          listTaskNewString.add(argumento['idDoc']);
          await SharedPrefe().setStringListValue('notiListChat', listTaskNewString);
          blocTaskReceived.inList.add(true);
          if(task != null){
            //ENVIADO
            if(isSend && page != bottonSelect.opcion3){
              updateNoti(3, true);
            }
            //RECIBIDO
            if(!isSend && page != bottonSelect.opcion2){
              updateNoti(0, true);
            }
          }
        }else{
          //ENVIADO O RECIBIDO
          if(isSend){
            _onTapNavigator(bottonSelect.opcion3);
            clickTarea(task);
          }else{
            _onTapNavigator(bottonSelect.opcion2);
            clickTarea(task);
          }
        }
      }
    }

    if(argumento['type'] == '1' &&
        (   argumento['table']  ==  'sms' ||
            argumento['table'] == 'tasks' ||
            argumento['table'] == 'tasksFinalized'||
            argumento['table'] == 'workingTask'||
            argumento['table'] == 'updateTask'
        )
    ){

      updateData.actualizarListaUsuarios(blocUser, blocConection);
      updateData.actualizarListaRecibidos(blocTaskReceived, blocConection, blocVerifyFirst: blocVerifyFirst);
      updateData.actualizarListaEnviados(blocTaskSend, blocConection);
      updateData.actualizarCasos(blocCasos);

      int idOpenTask = await SharedPrefe().getValue('openTask');
      int idTaskPush = 0;
      if(argumento['idDoc'] != null){
        idTaskPush = int.parse(argumento['idDoc']);
      }
      if(idOpenTask != idTaskPush){
        Tarea task;
        while(task == null){
          task = await DatabaseProvider.db.getCodeIdTask(idTaskPush.toString());
        }
        String subTitle = 'Nueva tarea: ';
        String description = task.name;
        bool isOnTap = true;
        if(argumento['table'] == 'tasksFinalized'){
          subTitle = 'Terminó la tarea ';
          isOnTap = false;
          description = '"$description"';
        }
        if(argumento['table'] == 'sms'){
          subTitle = 'Chat en "${task.name}": ';
          description = argumento['description'];
        }
        if(argumento['table'] == 'sms'){
          subTitle = 'Nueva mensaje:  ';
          description = argumento['description'];
        }
        if(argumento['table'] == 'workingTask'){
          subTitle = 'Comenzó a trabajar en la tarea:  ';
        }
        if(argumento['table'] == 'updateTask'){
          subTitle = 'Editó la tarea:  ';
        }
        viewNotiLocal(task, subTitle, description, isOnTap);
      }
    }

    if(argumento['type'] == '1' &&
        (argumento['table'] == 'projects' ||
            argumento['table'] == 'addToProject')){
      String subTitle = 'Te agregó a un proyecto: ';
      viewNotiLocalProjects(subTitle, argumento['idDoc']);
    }

    if(argumento['type'] == '1' &&
        argumento['table'] == 'reminderTask') {
      viewNotiLocalPersonal('Genial', 'Sigue así. ', 'Lo estás haciendo bien.');
    }

     */
  }

  Future<void> updateNoti(int index, bool value) async {
    if(index == 0){
      notiRecived = value;
    }
    if(index == 1){
      notiContacts = value;
    }
    if(index == 3){
      notiSend = value;
    }
    setState(() {});
  }

  Future<void> verifyNewTaskInvitation() async {
    setState(() {});
  }

  validateInvitation(List<InvitationModel> list) async {
    for(int x = 0; x < list.length; x++){
      if(list[x].read == 0){
        try{
          var res = await conexionHispanos.httpReadInvitation(list[x].id);
          print(res);
        }catch(_){}
      }
    }
  }

  List<Usuario> orderUserForDate(List<Usuario> listUser){
    List<Usuario> users = [];
    Map<int,Usuario> contacts = {};
    Map<int,Usuario> contacts2 = {};

    listUser.forEach((element) {
      if(element.contact == 1){ contacts[element.id] = element; contacts2[element.id] = element; }
    });

    for(int x = 1; x < contacts.length; x++){
      int idMax = 0;
      String dateMax = '';

      contacts2.forEach((key, value) {
        if(value.updatedAt.isNotEmpty){
          if(dateMax.isEmpty){
            idMax = key;
            dateMax = value.updatedAt;
          }else{
            DateTime dateCreate = DateTime.parse(dateMax);
            Duration difDays = dateCreate.difference(DateTime.now());

            DateTime dateCreate2 = DateTime.parse(value.updatedAt);
            Duration difDays2 = dateCreate2.difference(DateTime.now());

            if(difDays2.inSeconds > difDays.inSeconds){
              idMax = key;
              dateMax = value.updatedAt;
            }
          }
        }
      });

      contacts2.remove(idMax);
      if(contacts[idMax] != null){
        users.add(contacts[idMax]);
      }
    }

    contacts.forEach((key, value) {
      bool isHere = false;
      users.forEach((element) {
        if(element.id == key){
          isHere = true;
        }
      });
      if(!isHere){
        users.add(value);
      }
    });
    return users;
  }
}
