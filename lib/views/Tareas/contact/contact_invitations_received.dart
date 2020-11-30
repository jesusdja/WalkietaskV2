import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class InvitationsReceived extends StatefulWidget {
  InvitationsReceived({this.listInvitationRes, this.mapIdUsersRes});
  final Map<int,Usuario> mapIdUsersRes;
  final List<InvitationModel> listInvitationRes;

  @override
  _InvitationsReceivedState createState() => _InvitationsReceivedState();
}

class _InvitationsReceivedState extends State<InvitationsReceived> {

  List<InvitationModel> listInvitation;
  double alto = 0;
  double ancho = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listInvitation = widget.listInvitationRes;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    List<Widget> widgets = cardInvitation();

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
            avatarUser = Image.network('$directorioImage${userInvited.avatar}');
          }

          DateTime date = DateTime.parse(invitation.createdAt);
          String mes = date.month.toString(); if(mes.length < 2){ mes = '0$mes'; }
          String dia = date.day.toString(); if(dia.length < 2){ dia = '0$mes'; }
          String dateInvited = 'Enviada el $dia-$mes-${date.year}';

          result.add(
              Container(
                width: ancho,
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: alto * 0.02, left: ancho * 0.04, right: ancho * 0.02),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${userInvited.name}',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.018, color: WalkieTaskColors.color_4D4D4D),),
                          SizedBox(height: alto * 0.006,),
                          Text('$dateInvited', style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 0.5,),),
                          SizedBox(height: alto * 0.008,),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: alto * 0.02, right: ancho * 0.02),
                      child: Column(
                        children: <Widget>[
                          RoundedButton(
                            backgroundColor: WalkieTaskColors.primary,
                            title: 'Aceptar',
                            onPressed: (){},
                            radius: 5.0,
                            textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 1.5),
                            height: alto * 0.035,
                            width: ancho * 0.2,
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: alto * 0.02, right: ancho * 0.04),
                      child: Column(
                        children: <Widget>[
                          RoundedButton(
                            backgroundColor: WalkieTaskColors.color_DD7777,
                            title: 'Rechazar',
                            onPressed: (){},
                            radius: 5.0,
                            textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold, spacing: 1.5),
                            height: alto * 0.035,
                            width: ancho * 0.2,
                          )
                        ],
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
}
