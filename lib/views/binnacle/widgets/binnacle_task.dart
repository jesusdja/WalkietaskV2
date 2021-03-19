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
      _rowData = taskNew( size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
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
      projectName = '';
    }

    if(myUser.id == info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
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

  Widget taskPersonalReminder(Size size){
    return Container(
      width: size.width,
      child: Row(
        children: [

        ],
      ),
    );
  }
}
