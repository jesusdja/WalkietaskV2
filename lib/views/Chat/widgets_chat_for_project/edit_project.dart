import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class EditProject extends StatefulWidget {

  EditProject({
    @required this.project,
    @required this.widgetHome,
  });

  final Caso project;
  final Map<String,dynamic> widgetHome;

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {

  final controllerPage = PageController(initialPage: 0,);

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';
  Caso project;
  Map<String,dynamic> widgetHome;
  List<Usuario> listUser = [];
  List<Usuario> usersForProject = [];
  bool loadData = true;

  @override
  void initState() {
    super.initState();
    initialUser();
    project = widget.project;
    widgetHome = widget.widgetHome;
  }

  @override
  void dispose() {
    super.dispose();
    controllerPage.dispose();
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
    return Container(
      width: ancho,
      child: Column(
        children: [
          Container(),
          loadData ?
          Container(
            width: ancho,
            height: alto * 0.5,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) :
          Flexible(
            child: Container(),
          )
        ],
      ),
    );
  }

  Widget _appBarH(){
    String nombreUser = project.name ?? '';
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
                child: InkWell(
                  child: Container(
                    margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  ),
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

