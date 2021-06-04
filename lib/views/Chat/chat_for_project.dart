import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class ChatForProject extends StatefulWidget {

  ChatForProject({ @required this.project, @required this.widgetHome});

  final Caso project;
  final Map<String,dynamic> widgetHome;

  @override
  _ChatForProjectState createState() => _ChatForProjectState();
}

class _ChatForProjectState extends State<ChatForProject> {

  double alto = 0;
  double ancho = 0;
  String idMyUser = '0';

  Caso project;
  Map<String,dynamic> widgetHome;

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
  }


  initialUser() async {
    idMyUser = await SharedPrefe().getValue('unityIdMyUser');
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
      )
    );
  }

  Widget _appBarH(){
    String nombreUser = project.name ?? '';
    return AppBar(
      actions: <Widget>[
        Container(
          width: ancho,
          child: Row(
            children: <Widget>[
              InkWell(
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
              Expanded(
                  child: Text('$nombreUser',style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_3C3C3C),textAlign: TextAlign.center,),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.02),
                  child: Icon(Icons.info_outline, size: alto * 0.03,color: WalkieTaskColors.color_4EA0F0,),
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

