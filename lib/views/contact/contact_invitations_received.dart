import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class InvitationsReceived extends StatefulWidget {
  InvitationsReceived({this.mapIdUsersRes, this.blocInvitation, this.blocUser});
  final Map<int,Usuario> mapIdUsersRes;
  final BlocCasos blocInvitation;
  final BlocUser blocUser;

  @override
  _InvitationsReceivedState createState() => _InvitationsReceivedState();
}

class _InvitationsReceivedState extends State<InvitationsReceived> {

  List<InvitationModel> listInvitation;
  double alto = 0;
  double ancho = 0;

  Map<int,bool> mapInvitationAccepted = {};
  Map<int,bool> mapInvitationDenied = {};

  conexionHttp connectionHttp = new conexionHttp();
  StreamSubscription streamSubscriptionInvitation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inicializarPatronBlocInvitation();
    _inicializarInvitation();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscriptionInvitation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    List<Widget> widgets = listInvitation != null ?cardInvitation() : [];

    return Container(
      width: ancho,
      child: SingleChildScrollView(
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> cardInvitation(){
    List<Widget> result = [
      SizedBox(height: alto * 0.04,),
    ];
    listInvitation.forEach((invitation) {
      Usuario userInvited;
      try{
        userInvited = widget.mapIdUsersRes[invitation.userId];
        if(invitation.inv == 1 && userInvited != null){
          Image avatarUser = Image.network(avatarImage);
          if(userInvited.avatar.isNotEmpty){
            avatarUser = Image.network(userInvited.avatar);
          }

          DateTime date = DateTime.parse(invitation.createdAt);
          String mes = date.month.toString(); if(mes.length < 2){ mes = '0$mes'; }
          String dia = date.day.toString(); if(dia.length < 2){ dia = '0$mes'; }
          String dateInvited = 'Enviada el $dia-$mes-${date.year}';

          result.add(
              Container(
                width: ancho,
                margin: EdgeInsets.only(bottom: alto * 0.03),
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
                        radius: alto * 0.025,
                        backgroundImage: avatarUser.image,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${userInvited.name} ${userInvited.surname}',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D),),
                          Text('$dateInvited', style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 0.5,),),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.02, left: ancho * 0.02),
                      child: mapInvitationAccepted[invitation.id] ?
                      Container(
                        width: ancho * 0.18,
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
                        backgroundColor: WalkieTaskColors.primary,
                        title: 'Aceptar',
                        radius: 5.0,
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 0.5),
                        height: alto * 0.035,
                        width: ancho * 0.18,
                        onPressed: () async {
                          mapInvitationAccepted[invitation.id] = true;
                          setState(() {});
                          try{
                            var response = await connectionHttp.httpAcceptedInvitationReceived(invitation.userId);
                            var value = jsonDecode(response.body);
                            if(value['status_code'] == 200){
                              int res = await DatabaseProvider.db.deleteInvitation(invitation.id);
                              if(res != 0){
                                widget.blocInvitation.inList.add(true);
                                UpdateData updateData = new UpdateData();
                                updateData.actualizarListaContact(widget.blocUser);
                                showAlert('Invitación aceptada.',WalkieTaskColors.color_89BD7D);
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
                          mapInvitationAccepted[invitation.id] = false;
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.04),
                      child: mapInvitationDenied[invitation.id] ?
                      Container(
                        width: ancho * 0.18,
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
                        title: 'Rechazar',
                        radius: 5.0,
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 0.5),
                        height: alto * 0.035,
                        width: ancho * 0.18,
                        onPressed: () async {
                          mapInvitationDenied[invitation.id] = true;
                          setState(() {});
                          try{
                            var response = await connectionHttp.httpDeniedInvitationReceived(invitation.userId);
                            var value = jsonDecode(response.body);
                            if(value['status_code'] == 200){
                              int res = await DatabaseProvider.db.deleteInvitation(invitation.id);
                              if(res != 0){
                                widget.blocInvitation.inList.add(true);
                                showAlert('Invitación rechazada.',WalkieTaskColors.color_89BD7D);
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
                          mapInvitationDenied[invitation.id] = false;
                          setState(() {});
                        },
                      ),
                    )
                  ],
                ),
              )
          );
        }
      }catch(_){}


    });
    return result;
  }

  _inicializarPatronBlocInvitation(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionInvitation = widget.blocInvitation.outList.listen((newVal) {
        if(newVal){
          _inicializarInvitation();
        }
      });
    } catch (e) {}
  }

  _inicializarInvitation() async {
    listInvitation = await  DatabaseProvider.db.getAllInvitation();
    listInvitation.forEach((element) {
      mapInvitationAccepted[element.id] = false;
      mapInvitationDenied[element.id] = false;
    });
    setState(() {});
  }
}
