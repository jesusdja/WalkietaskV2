import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleInvitation extends StatelessWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleInvitation({
    @required this.type,
    @required this.info,
    @required this.myUser,
  });

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    TextStyle styleTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.02, fontWeight: FontWeight.bold, spacing: 1);
    TextStyle styleSubTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.015, spacing: 1);

    Widget _rowData = Container();

    if(info['category'] == 'contact'){
      if( type == 'deleted'){
        _rowData = contactDeleted(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
    }else{
      if( type == 'sent'){
        _rowData = invitationSend(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( type == 'received'){
        _rowData = invitationReceived(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( type == 'accepted'){
        _rowData = invitationAccepted(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( type == 'declined'){
        _rowData = invitationDeclined(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( type == 'deleted'){
        _rowData = invitationDeleted(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
    }
    return _rowData;
  }

  Widget viewImageAvatar({Size size, String urlAvatar}){
    return Container(
      padding: EdgeInsets.only(left: size.width * 0.01),
      child: Container(
        padding: const EdgeInsets.all(3.0), // borde width
        decoration: new BoxDecoration(
          color: bordeCirculeAvatar, // border color
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: size.height * 0.018,
          backgroundImage: Image.network(urlAvatar).image,
          //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
        ),
      ),
    );
  }

  Widget contactDeleted({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Eliminaste a un usuario de tu lista de contactos';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;

    if(info['info'] != null){
      title = 'Eliminaste a ${info['info']['contact']['name']} ${info['info']['contact']['surname'] ?? ''} de tu lista de contactos';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = avatarImage;
      title = 'Te eliminaron de su lista de contactos';
      if(info['info'] != null){
        title = '${info['useraction']['name']} ${info['useraction']['surname'] ?? ''} te elimino de su lista de contactos';
        urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      }
    }


    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationSend({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Enviaste una invitación';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;

    if(info['info'] != null){
      title = 'Enviaste una invitación a ${info['info']['contact']['name']} ${info['info']['contact']['surname'] ?? ''}';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = 'Recibiste una invitación de ${info['useraction']['name']} ${info['useraction']['surname'] ?? ''}';
    }


    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationReceived({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Recibiste una invitación de ${info['useraction']['name']} ${info['useraction']['surname'] ?? ''}';
    String urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;

    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationAccepted({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Aceptaste la invitacion';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;

    if(info['info'] != null){
      title = 'Aceptaste la invitacion de ${info['info']['user']['name']} ${info['info']['user']['surname'] ?? ''}';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = avatarImage;
      if(info['info'] != null){
        urlAvatar = info['info']['contact']['avatar_100']  ?? avatarImage;
        title = '${info['info']['contact']['name']} ${info['info']['contact']['surname'] ?? ''} acepto la invitacion';
      }
    }


    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationDeclined({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Rechazo la invitación';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;

    if(info['info'] != null){
      title = 'Rechazaste una invitación de ${info['info']['contact']['name']} ${info['info']['contact']['surname'] ?? ''}';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      if(info['info'] != null){
        title = '${info['info']['user']['name']} ${info['info']['user']['surname'] ?? ''} rechazo la invitación';
      }

    }


    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationDeleted({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Elimino la invitación';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;

    if(info['info'] != null){
      title = 'Eliminaste una invitación para ${info['info']['contact']['name']} ${info['info']['contact']['surname'] ?? ''}';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      if(info['info'] != null){
        title = '${info['info']['user']['name']} ${info['info']['user']['surname'] ?? ''} elimino la invitación';
      }

    }


    return Container(
      width: size.width,
      margin: isProperty ? EdgeInsets.only(left: size.width * 0.1) : EdgeInsets.only(right: size.width * 0.1),
      child: Column(
        crossAxisAlignment: isProperty ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: isProperty ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
