import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    initialUser();
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
      child: Scaffold()
    );
  }
}

