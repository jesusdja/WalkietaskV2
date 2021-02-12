import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/profile/profile_photo.dart';

class ProfileHome extends StatefulWidget {

  ProfileHome({@required this.myUser});

  final Usuario myUser;

  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {

  Usuario myUser;

  double alto = 0;
  double ancho = 0;

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text('Mi Cuenta',
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696),textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey,size: alto * 0.04,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: alto * 0.035,),
            _textTitle('Foto de perdil:'),
            SizedBox(height: alto * 0.03,),
            ProfilePhoto(myUser: myUser,),
            SizedBox(height: alto * 0.06,),
            _textTitle('Tus datos'),
            SizedBox(height: alto * 0.1,),
            _textTitle('Modificar clave de acceso'),
            SizedBox(height: alto * 0.1,),
            _textTitle('Recibir notificaciones:'),
            SizedBox(height: alto * 0.1,),
            _textTitle('Posición de botón de recordatorio:'),
          ],
        ),
      ),
    );
  }

  Widget _textTitle(String title){
    return Container(
      width: ancho,
      margin: EdgeInsets.only(left: ancho * 0.05),
      child: Text(title, style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.color_969696, fontWeight: FontWeight.bold),),
    );
  }


}
