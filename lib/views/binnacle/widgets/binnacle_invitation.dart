import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class BinnacleInvitation extends StatefulWidget {

  final String type;
  final Map<String,dynamic> info;
  final Usuario myUser;

  BinnacleInvitation({
    @required this.type,
    @required this.info,
    @required this.myUser,
  });

  @override
  _BinnacleInvitationState createState() => _BinnacleInvitationState();
}

class _BinnacleInvitationState extends State<BinnacleInvitation> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    TextStyle styleTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.02, fontWeight: FontWeight.bold, spacing: 1);
    TextStyle styleSubTitle = WalkieTaskStyles().stylePrimary(size: size.height * 0.015, spacing: 1);

    Widget _rowData = Container();

    if(widget.info['category'] == 'contact'){
      if( widget.type == 'deleted'){
        _rowData = contactDeleted(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
    }else{
      if( widget.type == 'sent'){
        _rowData = invitationSend(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( widget.type == 'received'){
        _rowData = invitationReceived(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( widget.type == 'accepted'){
        _rowData = invitationAccepted(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( widget.type == 'declined'){
        _rowData = invitationDeclined(size: size, styleTitle: styleTitle, styleSubTitle: styleSubTitle);
      }
      if( widget.type == 'deleted'){
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
    String title = translate(context: context, text: 'youDeletedUserFromList');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;

    if(widget.info['info'] != null){
      title = translate(context: context, text: 'youDeletedFromYourList').replaceAll('___', '${widget.info['info']['contact']['name']} ${widget.info['info']['contact']['surname'] ?? ''}');
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = avatarImage;
      title = translate(context: context, text: 'youWereDeletedFromList');
      if(widget.info['info'] != null){
        title = '${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''} ${translate(context: context, text: 'deletedYouFromHisList')}';
        urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
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
    String title = translate(context: context, text: 'youSentAnInvitation');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;

    if(widget.info['info'] != null){
      title = '${translate(context: context, text: 'youSentInvitation')} ${widget.info['info']['contact']['name']} ${widget.info['info']['contact']['surname'] ?? ''}';
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
      title = '${translate(context: context, text: 'youReceivedInvitationFrom')} ${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''}';
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
    String title = '${translate(context: context, text: 'youReceivedInvitationFrom')} ${widget.info['useraction']['name']} ${widget.info['useraction']['surname'] ?? ''}';
    String urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;

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
    String title = translate(context: context, text: 'youAcceptedInvitation');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;

    if(widget.info['info'] != null){
      title = '${translate(context: context, text: 'youAcceptedInvitationOf')} ${widget.info['info']['user']['name']} ${widget.info['info']['user']['surname'] ?? ''}';
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = avatarImage;
      if(widget.info['info'] != null){
        urlAvatar = widget.info['info']['contact']['avatar_100']  ?? avatarImage;
        title = '${widget.info['info']['contact']['name']} ${widget.info['info']['contact']['surname'] ?? ''} ${translate(context: context,text: 'acceptedInvitation')}';
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
    String title = translate(context: context, text: 'rejectedInvitation');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;

    if(widget.info['info'] != null){
      title = '${translate(context: context, text: 'youRejectedInvitationFrom')} ${widget.info['info']['contact']['name']} ${widget.info['info']['contact']['surname'] ?? ''}';
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
      if(widget.info['info'] != null){
        title = '${widget.info['info']['user']['name']} ${widget.info['info']['user']['surname'] ?? ''} ${translate(context: context, text: 'rejectedInvitation')}';
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
    String title = translate(context: context, text: 'deletedInvitation');
    String urlAvatar = widget.info['usernotification']['avatar_100']  ?? avatarImage;

    if(widget.info['info'] != null){
      title = '${translate(context: context, text: 'youDeletedInvitationSentTo')} ${widget.info['info']['contact']['name']} ${widget.info['info']['contact']['surname'] ?? ''}';
    }

    if(widget.myUser.id == widget.info['user_action_id']){
      //TAREA NUEVA QUE YO CREE
      isProperty = true;
    }else{
      //TAREA NUEVA QUE SE ME FUE ASIGNADA
      urlAvatar = widget.info['useraction']['avatar_100']  ?? avatarImage;
      if(widget.info['info'] != null){
        title = '${widget.info['info']['user']['name']} ${widget.info['info']['user']['surname'] ?? ''} ${translate(context: context, text: 'deletedTheInvitation')}';
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
