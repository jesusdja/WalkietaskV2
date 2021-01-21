import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteInvitation.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class InvitationsSent extends StatefulWidget {
  InvitationsSent({this.mapIdUsersRes, this.blocInvitation});
  final Map<int,Usuario> mapIdUsersRes;
  final BlocCasos blocInvitation;

  @override
  _InvitationsSentState createState() => _InvitationsSentState();
}

class _InvitationsSentState extends State<InvitationsSent> {

  List<InvitationModel> listInvitation;
  double alto = 0;
  double ancho = 0;

  conexionHttp connectionHttp = new conexionHttp();
  StreamSubscription streamSubscriptionInvitation;

  Map<int,bool> mapInvitationReset = {};
  Map<int,bool> mapInvitationDelete = {};

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
    List<Widget> result = [];
    listInvitation.forEach((invitation) {
      Usuario userInvited;
      try{
        userInvited = widget.mapIdUsersRes[invitation.userIdInvited];
        if(invitation.inv == 0 && userInvited != null){
          Image avatarUser = Image.network(avatarImage);
          if(userInvited.avatar.isNotEmpty){
            avatarUser = Image.network('$directorioImage${userInvited.avatar}');
          }

          DateTime date = DateTime.parse(invitation.createdAt);
          String mes = date.month.toString(); if(mes.length < 2){ mes = '0$mes'; }
          String dia = date.day.toString(); if(dia.length < 2){ dia = '0$mes'; }
          String dateInvited = 'Enviada el $dia-$mes-${date.year}';

          String nameUser = '${userInvited.name}';
          if(invitation.external == 1){
            nameUser = invitation.contact;
          }

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
                          Text(nameUser,style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_4D4D4D),maxLines: 1,),
                          Text('$dateInvited', style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.018, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 0.5,),maxLines: 1),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.02, left: ancho * 0.01),
                      child: mapInvitationReset[invitation.id] ?
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
                        title: 'Reenviar',
                        radius: 5.0,
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 0.5),
                        height: alto * 0.035,
                        width: ancho * 0.18,
                        onPressed: () async {
                          mapInvitationReset[invitation.id] = true;
                          setState(() {});
                          try{
                            var response = await connectionHttp.httpResetInvitationSent(invitation.userIdInvited);
                            var value = jsonDecode(response.body);
                            if(value['status_code'] == 200){
                              showAlert('Enviada con exito.',WalkieTaskColors.color_89BD7D);
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
                          mapInvitationReset[invitation.id] = false;
                          setState(() {});
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.04),
                      child: mapInvitationDelete[invitation.id] ?
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
                        title: 'Eliminar',
                        radius: 5.0,
                        textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 0.5),
                        height: alto * 0.035,
                        width: ancho * 0.18,
                        onPressed: () async {
                          mapInvitationDelete[invitation.id] = true;
                          setState(() {});
                          try{
                            var response = await connectionHttp.httpDeleteInvitationSent(invitation.userIdInvited);
                            var value = jsonDecode(response.body);
                            if(value['status_code'] == 200){
                              int res = await InvitationDatabaseProvider.db.deleteInvitation(invitation.id);
                              if(res != 0){
                                widget.blocInvitation.inList.add(true);
                                showAlert('Eliminada con exito.',WalkieTaskColors.color_89BD7D);
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
                          mapInvitationDelete[invitation.id] = false;
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
    listInvitation = await  InvitationDatabaseProvider.db.getAll();
    listInvitation.forEach((element) {
      mapInvitationReset[element.id] = false;
      mapInvitationDelete[element.id] = false;
    });
    setState(() {});
  }
}
