import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleTask extends StatelessWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleTask({
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

    if( type == 'new'){
      _rowData = taskNew(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'personalreminder'){
      _rowData = taskPersonalReminder(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'deleted'){
      _rowData = taskDelete(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'edited'){
      _rowData = taskEdit(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'priority'){
      _rowData = taskPriority(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'working'){
      _rowData = taskWorking(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( type == 'finalized'){
      _rowData = taskFinalized(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
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

  Widget taskNew({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Enviaste una tarea a ${info['info']['userresponsabilities']['name']} ${info['info']['userresponsabilities']['surname'] ?? ''}';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = 'Recibiste una tarea de ${info['useraction']['name']} ${info['useraction']['surname'] ?? ''}';
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
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget taskPersonalReminder({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){
    String title = 'Enviaste recordatorio personal';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    return Container(
      width: size.width,
      margin: EdgeInsets.only(left: size.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: TextAlign.end),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget taskDelete({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Eliminaste una tarea';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    if(myUser.id == info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = '${info['useraction']['name']} ${info['useraction']['surname'] ?? ''} elimino una tarea';
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
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget taskEdit({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Editaste una tarea';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    if(myUser.id == info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = '${info['useraction']['name']} ${info['useraction']['surname'] ?? ''} Editó una tarea';
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
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget taskPriority({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    String title = 'Indicaste como favorito la siguente tarea';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    return Container(
      width: size.width,
      margin: EdgeInsets.only(left: size.width * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                viewImageAvatar(size: size, urlAvatar: urlAvatar),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: TextAlign.end,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: TextAlign.end,),
          ),
        ],
      ),
    );
  }

  Widget taskWorking({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Comenzaste a trabajar en una tarea';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    if(myUser.id == info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = '${info['useraction']['name']} ${info['useraction']['surname'] ?? ''} comenzo a trabajar en una tarea';
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
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget taskFinalized({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = 'Finalizaste una tarea';
    String urlAvatar = info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = info['info']['name'];

    String projectName = '(Sin proyecto asignado)';
    if(info['info']['projects'] != null ){
      projectName = info['info']['projects']['name'];
    }

    if(myUser.id == info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = info['useraction']['avatar_100']  ?? avatarImage;
      title = '${info['useraction']['name']} ${info['useraction']['surname'] ?? ''} finalizo una tarea';
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
          Container(
            width: size.width,
            child: Text(nameTask, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(projectName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }
}
