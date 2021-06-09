import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/utils/Globales.dart';

class SelectedUserSendTask extends StatefulWidget {

  SelectedUserSendTask({
    @required this.widgetHome,
    @required this.isAudio,
  });

  final Map<String,dynamic> widgetHome;
  final bool isAudio;

  @override
  _SelectedUserSendTaskState createState() => _SelectedUserSendTaskState();
}

class _SelectedUserSendTaskState extends State<SelectedUserSendTask> {

  final controllerPage = PageController(initialPage: 0,);

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Map<String,dynamic> widgetHome;
  List<Usuario> listUser = [];
  List<Usuario> usersForProject = [];
  bool loadData = true;
  Usuario selectedUser;

  @override
  void initState() {
    super.initState();
    initialUser();
    widgetHome = widget.widgetHome;
  }

  initialUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');
    listUser = await DatabaseProvider.db.getAllUser();

    String usersProjects = widgetHome['info'].userprojects ?? '';
    List<String> data = usersProjects.split('|');
    data.forEach((idUserProject) {
      if(idUserProject != idMyUser){
        listUser.forEach((element) {
          if(element.id.toString() == idUserProject){
            usersForProject.add(element);
          }
        });
      }
    });

    loadData = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controllerPage.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: _appBarH(),
        body: body(),
      )
    );
  }

  Widget body(){

    List<Widget> users = cardUsers();

    return Container(
      width: ancho,
      child: loadData ?
      Container(
        width: ancho,
        height: alto * 0.5,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ) :
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: users,
        ),
      ),
    );
  }

  List<Widget> cardUsers(){
    List<Widget> users = [];
    try{

      usersForProject.forEach((user) {

        String userName = user != null ? user.name ?? '' : '';
        Widget avatarUserWidget = avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase());
        if(user != null){
          if(user != null && user.avatar_100 != ''){
            avatarUserWidget = avatarWidgetImage(alto: alto,pathImage: user.avatar_100);
          }
        }

        bool isSelect = false;
        if(selectedUser != null && selectedUser.id == user.id){
          isSelect = true;
        }

        users.add(

            InkWell(
              child: Container(
                width: ancho,
                padding: EdgeInsets.all(alto * 0.02),
                color: isSelect ? Colors.blue[100] : Colors.transparent,
                child: Row(
                  children: [
                    Center(
                      child: Container(
                        decoration: new BoxDecoration(
                          color: bordeCirculeAvatar, // border color
                          shape: BoxShape.circle,
                        ),
                        child: avatarUserWidget,
                      ),
                    ),
                    Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: ancho * 0.05),
                          child: Text('${user.name} ${user.surname}', style: WalkieTaskStyles().styleHelveticaneueRegular(fontWeight: FontWeight.bold,size: alto * 0.02,color: WalkieTaskColors.black,spacing: 0.5),),
                        )
                    ),
                    !isSelect ? Container() :
                    Container(
                      margin: EdgeInsets.only(right: ancho * 0.05),
                      child: Icon(Icons.check_circle,color: WalkieTaskColors.primary,size: alto * 0.04,),
                    )
                  ],
                ),
              ),
              onTap: (){
                if(selectedUser == null || selectedUser.id != user.id){
                  selectedUser = user;
                  setState(() {});
                }
              },
            )

        );

      });

      if(users.isEmpty){
        users.add(
          Container(
            width: ancho,
            margin: EdgeInsets.symmetric(vertical: alto * 0.15,horizontal: ancho * 0.1),
            child: Text(translate(context: context, text: 'noUsersToSubmitTasks'),
              style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, color: WalkieTaskColors.color_4D4D4D,spacing: 0.5),
              textAlign: TextAlign.center,),
          )
        );
      }
    }catch(e){
      print('cardUsers: ${e.toString()}');
    }
    return users;
  }

  Widget _appBarH(){
    String nombreUser = translate(context: context,text: 'selectUser');
    return AppBar(
      leading: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
        },
        child: Container(
          child: Center(
            child: Container(
              width: ancho * 0.1,
              height: alto * 0.06,
              child: Image.asset('assets/image/icon_close_option.png',fit: BoxFit.fill,color: Colors.grey,),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Container(
          width: ancho,
          child: Row(
            children: <Widget>[
              Container( width: ancho * 0.1, ),
              Expanded(
                  child: Text('$nombreUser',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C),textAlign: TextAlign.center,),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  //child: Icon(Icons.info_outline, size: alto * 0.03,color: WalkieTaskColors.color_4EA0F0,),
                ),
              ),
            ],
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
    );
  }
}

