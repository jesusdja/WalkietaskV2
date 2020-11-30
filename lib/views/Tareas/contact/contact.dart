import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/models/invitation.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/contact/contact_invitations_received.dart';
import 'package:walkietaskv2/views/Tareas/contact/contact_invitations_sent.dart';
import 'package:walkietaskv2/views/Tareas/contact/contact_send_invitation.dart';

class Contacts extends StatefulWidget {
  Contacts({this.myUserRes, this.mapIdUsersRes, this.listInvitation, this.blocInvitation});
  final Usuario myUserRes;
  final Map<int,Usuario> mapIdUsersRes;
  final List<InvitationModel> listInvitation;
  final BlocCasos blocInvitation;
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  Usuario myUser;
  Map<int,Usuario> mapIdUsers;
  double alto = 0;
  double ancho = 0;
  Map<int,bool> mapAppBar = {0:true,1:false,2:false};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myUser = widget.myUserRes;
    mapIdUsers = widget.mapIdUsersRes;
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: WalkieTaskColors.white,
      body: _contenido(),
    );
  }

  Widget _contenido() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: ancho,
            color: Colors.grey[100],
            child: _appBArMenu(),
          ),
          mapAppBar[2] ? Container() : Container(
            width: ancho,
            padding: EdgeInsets.all(alto * 0.015),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () async {
                  var result = await Navigator.push(context, new MaterialPageRoute(
                      builder: (BuildContext context) => new SendInvitation(myUserRes: myUser, mapIdUsersRes: mapIdUsers,)));
                  if(result as bool == true){
                    widget.blocInvitation.inList.add(true);
                  }
                },
                child: Icon(Icons.add_circle_outline, color: WalkieTaskColors.primary,size: alto * 0.04,),
              ),
            ),
          ),
          mapAppBar[0] ? _myContacts() : Container(),
          mapAppBar[1] ? InvitationsSent(mapIdUsersRes: widget.mapIdUsersRes,blocInvitation: widget.blocInvitation,) : Container(),
          mapAppBar[2] ? InvitationsReceived(listInvitationRes: widget.listInvitation, mapIdUsersRes: widget.mapIdUsersRes) : Container(),
        ],
      ),
    );
  }

  Widget _myContacts(){
    List<Widget> listCardContacts = [];
    mapIdUsers.forEach((key, user) {
      if(widget.myUserRes != null && user.id != widget.myUserRes.id && user.contact == 1){
        listCardContacts.add(_cardMyContacts(user));
      }
    });

    return Container(
      width: ancho,
      child: SingleChildScrollView(
        child: Column(
          children: listCardContacts,
        ),
      ),
    );
  }

  Widget _cardMyContacts(Usuario user){
    Image avatarUser = Image.network(avatarImage);
    if(user.avatar.isNotEmpty){
      avatarUser = Image.network('$directorioImage${user.avatar}');
    }
    return Container(
      width: ancho,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: alto * 0.02, left: ancho * 0.04, right: ancho * 0.04),
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
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${user.name}',style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.color_4D4D4D, fontWeight: FontWeight.bold,spacing: 1.5),),
                  Text('${user.email}',style: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.color_ACACAC, fontWeight: FontWeight.bold,spacing: 1.5),),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: alto * 0.02, right: ancho * 0.04),
            child: Column(
              children: <Widget>[
                RoundedButton(
                  backgroundColor: WalkieTaskColors.color_DD7777,
                  title: 'Eliminar',
                  onPressed: (){},
                  radius: 5.0,
                  textStyle: WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022,color: WalkieTaskColors.white,fontWeight: FontWeight.bold),
                  height: alto * 0.04,
                  width: ancho * 0.2,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _appBArMenu(){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.05, top: alto * 0.007,),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _appBArMenuText('MIS CONTACTOS',0),
          ),
          Expanded(
            child: _appBArMenuText('INV. ENVIADAS',1),
          ),
          Expanded(
            child: _appBArMenuText('INV. RECIBIDAS',2),
          ),
        ],
      ),
    );
  }

  Widget _appBArMenuText(String text, int index){
    return InkWell(
      onTap: (){
        mapAppBar[0] = false;
        mapAppBar[1] = false;
        mapAppBar[2] = false;
        mapAppBar[index] = true;
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          Text(text, style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.016, color: WalkieTaskColors.primary),),
          mapAppBar[index] ? Container(
            width: ancho * 0.2,
            height: alto * 0.007,
            decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              color: WalkieTaskColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
