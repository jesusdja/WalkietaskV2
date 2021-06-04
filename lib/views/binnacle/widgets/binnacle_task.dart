import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleTask extends StatefulWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleTask({
    @required this.type,
    @required this.info,
    @required this.myUser,
  });

  @override
  _BinnacleTaskState createState() => _BinnacleTaskState();
}

class _BinnacleTaskState extends State<BinnacleTask> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    TextStyle styleTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.02, fontWeight: FontWeight.bold, spacing: 1);
    TextStyle styleSubTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.015, spacing: 1);

    Widget _rowData = Container();

    if( widget.type == 'new'){
      _rowData = taskNew(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'personalreminder'){
      _rowData = taskPersonalReminder(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'deleted'){
      _rowData = taskDelete(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'edited'){
      _rowData = taskEdit(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'priority'){
      _rowData = taskPriority(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'working'){
      _rowData = taskWorking(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }
    if( widget.type == 'finalized'){
      _rowData = taskFinalized(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }

    return _rowData;
  }

  Widget viewImageAvatar({Size size, String urlAvatar, @required String name}){
    return Container(
      padding: EdgeInsets.only(left: size.width * 0.01),
      child: Container(
        padding: const EdgeInsets.all(3.0), // borde width
        decoration: new BoxDecoration(
          color: bordeCirculeAvatar, // border color
          shape: BoxShape.circle,
        ),
        child: urlAvatar.isNotEmpty ? CircleAvatar(
          radius: size.height * 0.018,
          backgroundImage: Image.network(urlAvatar).image,
          //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
        ) :
        avatarWidget(alto: size.height,text: name.isEmpty ? '' : name.substring(0,1).toUpperCase(),radius: 0.018),
      ),
    );
  }

  Widget taskNew({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = translate(context: context, text: 'taskSentTo');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      title = '$title ${widget.info['info']['userresponsabilities']['name']} ${widget.info['info']['userresponsabilities']['surname'] ?? ''}';
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? '';
      nameUser = widget.info['useraction']['name'];
      title = '${translate(context: context, text: 'taskReceived')} ${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''}';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
    String title = translate(context: context, text: 'youSentPersonalReminder');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
    String title = translate(context: context, text: 'youDeletedTask');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = widget.info['useraction']['avatar_100']  ?? '';
      nameUser = widget.info['useraction']['name'];
      title = '${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''} ${translate(context: context, text: 'deletedTask')}';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
    String title = translate(context: context,text: 'youEditedTask');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = widget.info['useraction']['avatar_100']  ?? '';
      nameUser = widget.info['useraction']['name'];
      title = '${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''} ${translate(context: context, text: 'editedTask')}';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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

    String title = translate(context: context, text: 'youHighlightedTask');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
    String title = translate(context: context, text: 'youStartedWorkingTask');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = widget.info['useraction']['avatar_100']  ?? '';
      nameUser = widget.info['useraction']['name'];
      title = '${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''} ${translate(context: context, text: 'startedWorkingTask')}';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
    String title = translate(context: context, text: 'youCompletedTask');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? '';
    String nameUser = widget.info['usernotification']['name'];
    String nameTask = '';
    String projectName = translate(context: context, text: 'noAssignedProject');

    if(widget.info['info'] != null){
      nameTask = widget.info['info']['name'];
      if(widget.info['info']['projects'] != null ){
        projectName = widget.info['info']['projects']['name'];
      }
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      isProperty = true;
    }else{
      urlAvatar = widget.info['useraction']['avatar_100']  ?? '';
      nameUser = widget.info['useraction']['name'];
      title = '${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''} ${translate(context: context, text: 'completedTask')}';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar, name: nameUser),
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
