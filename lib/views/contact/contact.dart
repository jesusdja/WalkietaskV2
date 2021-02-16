import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/Notification/push_notifications_provider.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/DialogAlert.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/contact/contact_invitations_received.dart';
import 'package:walkietaskv2/views/contact/contact_invitations_sent.dart';
import 'package:walkietaskv2/views/contact/contact_send_invitation.dart';

class Contacts extends StatefulWidget {
  Contacts({this.myUserRes, this.mapIdUsersRes, this.listInvitation,
    this.blocInvitation, this.blocUser, this.push});
  final Usuario myUserRes;
  final Map<int,Usuario> mapIdUsersRes;
  final List<InvitationModel> listInvitation;
  final BlocCasos blocInvitation;
  final BlocUser blocUser;
  final PushProvider push;
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  Usuario myUser;
  Map<int,Usuario> mapIdUsers;
  double alto = 0;
  double ancho = 0;
  Map<int,bool> mapAppBar = {0:true,1:false,2:false};

  StreamSubscription streamSubscriptionUser;

  Map<int,bool> mapUserDelete = {};

  BlocUser blocUser;
  BlocCasos blocInvitation;

  UpdateData updateData = new UpdateData();

  conexionHttp connectionHttp = new conexionHttp();

  bool activeRecived = false;
  bool inInvitedRecived = false;

  @override
  void initState() {
    super.initState();
    myUser = widget.myUserRes;
    mapIdUsers = widget.mapIdUsersRes;
    blocUser = widget.blocUser;
    blocInvitation = widget.blocInvitation;
    _inicializar();
    _inicializarPatronBlocUser();
    _notificationListener();
  }

  _inicializar() async {
    mapIdUsers.forEach((key, user) {
      if(widget.myUserRes != null && user.id != widget.myUserRes.id && user.contact == 1){
        mapUserDelete[user.id] = false;
      }
    });
    setState(() {});
  }

  _initializarActive() async {
    activeRecived = await SharedPrefe().getValue('notiContacts_received');
    activeRecived = activeRecived ?? false;
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionUser?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;
    _initializarActive();

    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      body: _contenido(),
    );
  }

  Widget _contenido() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: ancho,
            color: Colors.grey[100],
            child: _appBArMenu(),
          ),
          mapAppBar[2] ? Container() : Container(
            width: ancho,
            padding: EdgeInsets.all(alto * 0.015),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  try{
                    var result = await Navigator.push(context, new MaterialPageRoute(
                        builder: (BuildContext context) => new SendInvitation(myUserRes: myUser, mapIdUsersRes: mapIdUsers,)));
                    if(result){
                      await updateData.actualizarListaInvitationSent(blocInvitation, null);
                    }
                  }catch(e){
                    print(e.toString());
                  }
                },
                child: Icon(Icons.add_circle_outline, color: WalkieTaskColors.primary,size: alto * 0.04,),
              ),
            ),
          ),
          mapAppBar[0] ? _myContacts() : Container(),
          mapAppBar[1] ? InvitationsSent(mapIdUsersRes: widget.mapIdUsersRes,blocInvitation: widget.blocInvitation,) : Container(),
          mapAppBar[2] ? InvitationsReceived(blocInvitation: widget.blocInvitation, mapIdUsersRes: widget.mapIdUsersRes, blocUser: blocUser,) : Container(),
        ],
      ),
    );
  }

  Widget _myContacts(){
    List<Widget> listCardContacts = [];
    mapIdUsers.forEach((key, user) {
      if(widget.myUserRes != null && user.id != widget.myUserRes.id && user.contact == 1){
        listCardContacts.add(_cardMyContacts(user));
      }
    });

    return Container(
      width: ancho,
      child: SingleChildScrollView(
        child: Column(
          children: listCardContacts,
        ),
      ),
    );
  }

  Widget _cardMyContacts(Usuario user){
    Image avatarUser = Image.network(avatarImage);
    if(user.avatar.isNotEmpty){
      avatarUser = Image.network(user.avatar);
    }
    return Container(
      width: ancho,
      margin: EdgeInsets.only(bottom: alto * 0.04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: ancho * 0.04, right: ancho * 0.02),
            padding: const EdgeInsets.all(2.0), // borde width
            decoration: new BoxDecoration(
              color: bordeCirculeAvatar, // border color
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: alto * 0.03,
              backgroundImage: avatarUser.image,
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('${user.name} ${user.surname}',style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D, fontWeight: FontWeight.bold,spacing: 1),),
                  Text('${user.email}',style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 1.5),maxLines: 1,),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: ancho * 0.04, left: ancho * 0.02),
            child: mapUserDelete[user.id] ?
            Container(
              width: ancho * 0.2,
              child: Center(
                child: Container(
                  width: alto * 0.03,
                  height: alto * 0.03,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
                :
            RoundedButton(
              backgroundColor: WalkieTaskColors.color_DD7777,
              title: 'Eliminar',
              radius: 5.0,
              textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 0.5),
              height: alto * 0.035,
              width: ancho * 0.18,
              onPressed: () async {
                mapUserDelete[user.id] = true;
                setState(() {});

                bool res = false;
                res = await alertDeleteElement(context,'¿Estas segudo que deseas eliminar tu contacto ${user.name} ${user.surname}');
                if(res != null && res){
                  try{
                    var response = await connectionHttp.httpDeleteContact(user.id);
                    var value = jsonDecode(response.body);
                    if(value['status_code'] == 200){
                      user.contact = 0;
                      int res = await DatabaseProvider.db.updateUser(user);
                      if(res != 0){
                        await updateData.actualizarListaContact(blocUser);
                        showAlert('Contacto eliminado.',WalkieTaskColors.color_89BD7D);
                        setState(() {});
                      }
                    }else{
                      if(value['message'] != null){
                        showAlert(value['message'],WalkieTaskColors.color_E07676);
                      }else{
                        showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                      }
                    }
                  }catch(e){
                    print(e.toString());
                    showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                  }
                }
                mapUserDelete[user.id] = false;
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _appBArMenu(){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05, top: alto * 0.007,),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _appBArMenuText('MIS CONTACTOS',0),
          ),
          Expanded(
            child: _appBArMenuText('INV. ENVIADAS',1),
          ),
          Expanded(
            child: Stack(
              children: [
                _appBArMenuText('INV. RECIBIDAS',2),
                (!mapAppBar[2] && activeRecived) ? Container(
                  margin: EdgeInsets.only(right: ancho * 0.003),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.circle, color: WalkieTaskColors.primary,size: alto * 0.015,),
                  ),
                ) : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBArMenuText(String text, int index){

    return InkWell(
      onTap: () async {
        mapAppBar[0] = false;
        mapAppBar[1] = false;
        mapAppBar[2] = false;
        mapAppBar[index] = true;
        if(index == 0){
          updateData.actualizarListaUsuarios(blocUser, null);
          inInvitedRecived = false;
        }
        if(index == 1){
          updateData.actualizarListaInvitationSent(blocInvitation, null);
          inInvitedRecived = false;
        }
        if(index == 2){
          updateData.actualizarListaInvitationReceived(blocInvitation, null);
          await SharedPrefe().setBoolValue('notiContacts_received', false);
          activeRecived = false;
          inInvitedRecived = true;
        }
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          Text(text, style: WalkieTaskStyles().stylePrimary(size: alto * 0.015, color: WalkieTaskColors.primary),),
          mapAppBar[index] ? Container(
            width: ancho * 0.2,
            height: alto * 0.007,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: WalkieTaskColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ) : Container(),
        ],
      ),
    );
  }

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

  _inicializarUser() async {
    List<Usuario> listaUser = await  DatabaseProvider.db.getAllUser();
    mapIdUsers = new Map();
    for(int x = 0; x < listaUser.length; x++){
      mapIdUsers[listaUser[x].id] = listaUser[x];
      mapUserDelete[listaUser[x].id] = false;
    }
    if (this.mounted) {
      setState(() {});
    }

  }

  void _notificationListener(){
    widget.push.mensajes.listen((argumento) async {
      int counter = await SharedPrefe().getValue('unityLogin');
      if(counter == 1){
        if(argumento['table'] != null && argumento['table'].contains('contacts')) {
          String idDoc = argumento['idDoc'];
          if(!inInvitedRecived){
            activeRecived = true;
            setState(() {});
          }else{
            updateData.actualizarListaInvitationReceived(blocInvitation, null);
          }
        }
      }
    });
  }
}
