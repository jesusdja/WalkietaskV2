import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';


class CreateTask extends StatefulWidget {

  CreateTask({
    @required this.blocUserRes,
    @required this.listUserRes,
    @required this.mapIdUserRes,
    @required this.myUserRes,
    @required this.listaCasosRes,
    @required this.blocTaskReceived,
    @required this.blocTaskSend,
    @required this.blocIndicatorProgress,
    @required this.listRecibidos,
    @required this.listEnviadosRes,
  });

  final Map<int,Usuario> mapIdUserRes;
  final List<Usuario> listUserRes;
  final List<Caso> listaCasosRes;
  final List<Tarea> listEnviadosRes;
  final List<Tarea> listRecibidos;
  final Usuario myUserRes;
  final BlocUser blocUserRes;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocProgress blocIndicatorProgress;

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  double alto = 0;
  double ancho = 0;
  TextStyle textStylePrimary;
  TextStyle textStylePrimaryLitle;
  TextStyle textStylePrimaryBold;

  List<Tarea> listEnviados = [];
  List<Tarea> listRecibidos = [];
  List<Usuario> listUser = [];
  List<Caso> listaCasos = [];

  Map<int,Usuario> mapIdUser = {};

  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStylePrimary = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.02, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.black, spacing: 1);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black);

    listEnviados = widget.listEnviadosRes;
    listRecibidos = widget.listRecibidos;
    listUser = widget.listUserRes;
    listaCasos = widget.listaCasosRes;
    mapIdUser = widget.mapIdUserRes;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        backgroundColor: WalkieTaskColors.white,
        body: listUser.isEmpty ? _taskIsEmpty() : _taskForUsers(),
      ),
    );
  }

  Widget _taskIsEmpty(){
    return Container(
      width: ancho,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: alto * 0.05, left: ancho * 0.06, right: ancho * 0.06),
            width: ancho,
            child: Text('Aquí aparecerán los usuarios a los que podrás enviar tareas o de los que las recibirás.',style: textStylePrimary, textAlign: TextAlign.left,),
          ),
          SizedBox(height: alto * 0.02,),
          Container(
            padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
            width: ancho,
            child: Text('Comienza invitando gente aquí',
              style: textStylePrimary, textAlign: TextAlign.left,),
          ),
          SizedBox(height: alto * 0.04,),
          Container(
            padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
            height: alto * 0.25,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ViewImage().assetsImage("assets/image/image_home_empty.png").image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: alto * 0.04,),
          Container(
            padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
            child: Divider(),
          ),
          SizedBox(height: alto * 0.04,),
          Container(
            padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
            width: ancho,
            child: Text('También puedes enviarte recordatorios personales, ya sea de audio o texto:',
              style: textStylePrimary, textAlign: TextAlign.left,),
          ),
          SizedBox(height: alto * 0.02,),
          _reminderPersonal(),
        ],
      ),
    );
  }

  Widget _reminderPersonal(){
    return Container(
      padding: EdgeInsets.only(left: ancho * 0.03, right: ancho * 0.03),
      width: ancho,
      child: Row(
        children: [
          Container(
            height: alto * 0.06,
            width: alto * 0.06,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ViewImage().assetsImage("assets/image/icon_personal.png").image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: ancho * 0.02),
              width: ancho,
              child: Text('Yo (recordatorio personal)',
                style: textStylePrimaryBold, textAlign: TextAlign.left,),
            ),
          ),
          Container(
            width: ancho * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sin Fecha',style: textStylePrimaryLitle,),
                Text('Recordatorio: 0',style: textStylePrimaryLitle,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskForUsers(){
    return Container(
      width: ancho,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: _users(),
        ),
      ),
    );
  }

  List<Widget> _users(){

    List<Widget> users = [];

    users.add(SizedBox(height: alto * 0.03,));

    listUser.forEach((user) {

      if(widget.myUserRes.id == null || user.id == widget.myUserRes.id || user.contact == 0) return Container();

      Image avatarUser = Image.network(avatarImage);
      if(user.avatar.isNotEmpty){
        avatarUser = Image.network('$directorioImage${user.avatar}');
      }

      bool favorite = user.fijo == 1;

      users.add(
        Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            width: ancho,
            margin: EdgeInsets.only(bottom: alto * 0.01, right: ancho * 0.03),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: ancho * 0.03, right: ancho * 0.03),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          decoration: new BoxDecoration(
                            color: bordeCirculeAvatar, // border color
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: alto * 0.03,
                            backgroundImage: avatarUser.image,
                            //child: Icon(Icons.account_circle,size: 49,color: Colors.white,),
                          ),
                        ),
                      ),
                      favorite ? Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.only(top: alto * 0.035, left: ancho * 0.08),
                          child: Icon(Icons.star,color: WalkieTaskColors.color_FAE438, size: alto * 0.03,),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                Expanded(child: Text(user.name, style: textStylePrimaryBold,)),
                Container(
                  width: ancho * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Sin Fecha',style: textStylePrimaryLitle,),
                      Text('Recibidas: 100',style: textStylePrimaryLitle,),
                      Text('Enviadas: 100',style: textStylePrimaryLitle,),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            _buttonSliderAction(user.fijo == 0 ? 'DESTACAR' : 'OLVIDAR',Icon(Icons.star,color: WalkieTaskColors.white,size: alto * 0.045,),Colors.yellow[600],WalkieTaskColors.white,1, user),
          ],
        ),

      );
      users.add(
        Container(
          padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
          child: Divider(),
        )
      );
    });

    users.add(_reminderPersonal());

    return users;
  }

  Widget _buttonSliderAction(String titulo,Icon icono,Color color,Color colorText,int accion, Usuario user){
    return IconSlideAction(
      color: color,
      iconWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icono,
          Text('$titulo',style: estiloLetras(alto * 0.013, Colors.white,fontFamily: 'helveticaneue2'),),
        ],
      ),
      onTap: () async {
        int res = 0;
        user.fijo = user.fijo == 1 ? 0 : 1;
        res = await  UserDatabaseProvider.db.updateUser(user);
        print('');
        if(res == 1){
          widget.blocUserRes.inList.add(true);
        }
      },
    );
  }
}