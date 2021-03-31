import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleProjects extends StatefulWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleProjects({
    @required this.type,
    @required this.info,
    @required this.myUser,
  });

  @override
  _BinnacleProjectsState createState() => _BinnacleProjectsState();
}

class _BinnacleProjectsState extends State<BinnacleProjects> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    TextStyle styleTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.02, fontWeight: FontWeight.bold, spacing: 1);

    Widget _rowData = Container();

    if( widget.type == 'new'){
      _rowData = projectsNew(size: size, styleTitle: styleTitle);
    }

    if( widget.type == 'deleted'){
      _rowData = projectsDeleted(size: size, styleTitle: styleTitle);
    }

    if( widget.type == 'added'){
      _rowData = projectsAddUser(size: size, styleTitle: styleTitle);
    }

    if( widget.type == 'deleteuserproject'){
      _rowData = projectsDeletedUser(size: size, styleTitle: styleTitle);
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

  Widget projectsNew({Size size, TextStyle styleTitle}){

    String title = translate(context: context, text: 'createdProject');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = '';
    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
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
        ],
      ),
    );
  }

  Widget projectsDeleted({Size size, TextStyle styleTitle}){
    String title = translate(context: context, text: 'deletedProject');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;
    String nameTask = translate(context: context, text: 'noName');
    if(widget.info['info'] != null && widget.info['info']['name'] != null){
      nameTask = widget.info['info']['name'];
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
        ],
      ),
    );
  }

  Widget projectsAddUser({Size size, TextStyle styleTitle}){

    bool isProperty = false;

    String projectName = translate(context: context, text: 'noName');
    if(widget.info['info'] != null && widget.info['info']['projects']['name'] != null ){
      projectName = widget.info['info']['projects']['name'];
    }

    String title = translate(context: context, text: 'addedToProject').replaceAll('___', '${widget.info['usernotification']['name']} ${widget.info['usernotification']['surname'] ?? ''}');
    String urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
      title = translate(context: context, text: 'youAddedToProject');
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
            child: Text(projectName, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget projectsDeletedUser({Size size, TextStyle styleTitle}){

    bool isProperty = false;

    String projectName = translate(context: context, text: 'noName');
    if(widget.info['info'] != null && widget.info['info']['projects']['name'] != null ){
      projectName = widget.info['info']['projects']['name'];
    }

    String title = translate(context: context, text: 'youDeletedFromYourList').replaceAll('___', '${widget.info['usernotification']['name']} ${widget.info['usernotification']['surname'] ?? ''}');
    String urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
      title = translate(context: context, text: 'youDeletedFromProject');
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
            child: Text(projectName, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }
}
