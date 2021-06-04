import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleChat extends StatefulWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleChat({
    @required this.type,
    @required this.info,
    @required this.myUser,
  });

  @override
  _BinnacleChatState createState() => _BinnacleChatState();
}

class _BinnacleChatState extends State<BinnacleChat> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    TextStyle styleTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.02, fontWeight: FontWeight.bold, spacing: 1);
    TextStyle styleSubTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.015, spacing: 1);

    Widget _rowData = Container();

    if( widget.type == 'toUser'){
      _rowData = chatToUser(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }

    if( widget.type == 'fromUser'){
      _rowData = chatFromUser(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
    }

    return _rowData;
  }

  Widget viewImageAvatar({Size size, String urlAvatar,String name = ''}){
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
        avatarWidget(alto: size.height,text: name.isEmpty ? '' : name.substring(0,1).toUpperCase(), radius: 0.018),
      ),
    );
  }

  Widget chatToUser({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = true;
    String title = translate(context: context, text: 'chat_1');
    String textChat = '"${widget.info['info']['texto']}"' ?? '';
    String urlAvatar = widget.myUser.avatar_100 ?? '';
    String taskName = '${translate(context: context, text: 'tasks').substring(0,translate(context: context, text: 'tasks').length - 1)}: ';
    String nameUser = widget.myUser.name ?? '';
    if(widget.info['task'] != null){
      taskName = '$taskName ${widget.info['task']['name']}';
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
            child: Text(textChat, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(taskName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }

  Widget chatFromUser({Size size, TextStyle styleTitle, TextStyle styleSubTitle}){

    bool isProperty = false;
    String title = translate(context: context, text: 'chat_2');
    String textChat = '"${widget.info['info']['texto']}"' ?? '';
    String urlAvatar = widget.myUser.avatar_100 ?? '';
    String taskName = '${translate(context: context, text: 'tasks').substring(0,translate(context: context, text: 'tasks').length - 1)}: ';
    String nameUser = widget.myUser.name ?? '';
    if(widget.info['task'] != null){
      taskName = widget.info['task']['name'];
    }

    if(widget.info['userFrom'] != null){
      urlAvatar = widget.info['userFrom']['avatar_100'] ?? '';
      title = '${widget.info['userFrom']['name']} ${widget.info['userFrom']['surname']} ${translate(context: context, text: 'chat_3')}';
      nameUser = widget.info['userFrom']['name'] ?? '';
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
                viewImageAvatar(size: size, urlAvatar: urlAvatar,name: nameUser),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(title, softWrap: true, overflow: TextOverflow.fade,style: styleTitle,),
                ),
              ],
            ),
          ),
          Container(
            width: size.width,
            child: Text(textChat, style: styleTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
          Container(
            width: size.width,
            child: Text(taskName, style: styleSubTitle,softWrap: false, overflow: TextOverflow.fade,textAlign: isProperty ? TextAlign.end : TextAlign.start,),
          ),
        ],
      ),
    );
  }
}
