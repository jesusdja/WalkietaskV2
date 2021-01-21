import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/bloc/blocUser.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/task_sound.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/Create/detalles_tareas_user.dart';


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
    @required this.mapDataUserHome,
    @required this.updateData,
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
  final Map<int,List> mapDataUserHome;
  final UpdateData updateData;

  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {

  bool iconBuscador = false;

  double alto = 0;
  double ancho = 0;

  TextStyle textStylePrimary;
  TextStyle textStylePrimaryLitle;
  TextStyle textStylePrimaryBold;
  TextStyle textStylePrimaryLitleRed;
  TextStyle textStylePrimaryLitleBold;
  TextStyle textStylePrimaryTitleBold;
  TextStyle textStylePrimaryBoldName;

  List<Tarea> listEnviados = [];
  List<Tarea> listRecibidos = [];
  List<Usuario> listUser = [];
  List<Caso> listaCasos = [];

  Map<int,Usuario> mapIdUser = {};
  Map<int,List> mapDataUserHome = {};

  TextEditingController controlleBuscador = TextEditingController();

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
    textStylePrimaryLitleRed = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.color_DD7777, spacing: 1, fontWeight: FontWeight.bold);
    textStylePrimaryLitleBold = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.015, color: WalkieTaskColors.black, spacing: 1,);
    textStylePrimaryBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.02, color: WalkieTaskColors.black,);
    textStylePrimaryTitleBold = WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.028, color: WalkieTaskColors.black);
    textStylePrimaryBoldName = WalkieTaskStyles().styleHelveticaneueRegular(fontWeight: FontWeight.bold,size: alto * 0.02,color: WalkieTaskColors.black,spacing: 0.5);

    listEnviados = widget.listEnviadosRes;
    listRecibidos = widget.listRecibidos;
    listUser = widget.listUserRes;
    listaCasos = widget.listaCasosRes;
    mapIdUser = widget.mapIdUserRes;
    mapDataUserHome = widget.mapDataUserHome;

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

    String dateDiff = 'Sin fecha';
    int cant = 0;
    bool redColor = false;
    if(widget.myUserRes != null && mapDataUserHome[widget.myUserRes.id] != null){
      if(mapDataUserHome[widget.myUserRes.id][0] != ''){
        dateDiff = getDayDiff(mapDataUserHome[widget.myUserRes.id][0]);
        redColor = dateDiff.contains('Hace');
      }
      cant = mapDataUserHome[widget.myUserRes.id][2].length;
    }

    return InkWell(
      onTap: () => _onTapUser(widget.myUserRes, true),
      child: Container(
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
                child: Text('Yo (Recordatorios personales)',
                  style: textStylePrimaryBoldName, textAlign: TextAlign.left,),
              ),
            ),
            Container(
              width: ancho * 0.26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  redColor ?
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                          height: alto * 0.02,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(width: ancho * 0.02),
                        Text(dateDiff,style: textStylePrimaryLitleRed,)
                      ],
                    ),
                  )
                      :
                  Text(dateDiff,style: textStylePrimaryLitleBold,),
                  Text('Recordatorio: $cant',style: textStylePrimaryLitle,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskForUsers(){

    return Container(
      margin: EdgeInsets.only(top: alto * 0.01),
      width: ancho,
      child: CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: alto * 0.1,
            title: Container(
              width: ancho,
              child: Column(
                children: [
                  Container(
                    width: ancho,
                    child: Text('Buscar', style: textStylePrimaryTitleBold,),
                  ),
                  SizedBox(height: alto * 0.01,),
                  buscador(),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              iconBuscador ? resultSearch() : _users()
            ]),
          ),
        ],
      ),
    );
  }

  Widget _users(){

    List<Widget> users = [];

    users.add(SizedBox(height: alto * 0.03,));

    listUser.forEach((user) {

      if(widget.myUserRes.id == null || user.id == widget.myUserRes.id || user.contact == 0) return Container();

      Image avatarUser = Image.network(avatarImage);
      if(user.avatar.isNotEmpty){
        avatarUser = Image.network('$directorioImage${user.avatar}');
      }

      bool favorite = user.fijo == 1;

      String dateDiff = 'Sin fecha';
      int cantRecived = 0;
      int cantSend = 0;
      bool redColor = false;
      if(mapDataUserHome[user.id] != null){
        if(mapDataUserHome[user.id][0] != ''){
          dateDiff = getDayDiff(mapDataUserHome[user.id][0]);
          redColor = dateDiff.contains('Hace');
        }
        cantRecived = mapDataUserHome[user.id][1].length;
        cantSend = mapDataUserHome[user.id][2].length;
      }

      users.add(
        InkWell(
          onTap: () => _onTapUser(user, false),
          child: Slidable(
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
                  Expanded(child: Text(user.name, style: textStylePrimaryBoldName,)),
                  Container(
                    width: ancho * 0.3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        redColor ?
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                                height: alto * 0.02,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(width: ancho * 0.02),
                              Text(dateDiff,style: textStylePrimaryLitleRed,)
                            ],
                          ),
                        )
                            :
                        Text(dateDiff,style: textStylePrimaryLitleBold,),
                        Text('Recibidas: $cantRecived',style: textStylePrimaryLitle,),
                        Text('Enviadas: $cantSend',style: textStylePrimaryLitle,),
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

    users.add(SizedBox(height: alto * 0.03,));

    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children:  users,
        ),
      ),
    );
  }

  void _onTapUser(Usuario user, bool personal){
    Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) =>
        new DetailsTasksForUser(
          user: user,
          isPersonal: personal,
          mapDataUserHome: mapDataUserHome,
          listaCasos: listaCasos,
          blocTaskSend: widget.blocTaskSend,
          blocTaskReceived: widget.blocTaskReceived,
          blocIndicatorProgress: widget.blocIndicatorProgress,
          updateData: widget.updateData,
        )));
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

  String getDayDiff(String deadLine){
    String daysLeft = '';
    if(deadLine.isNotEmpty){
      daysLeft = 'Ahora';
      DateTime dateCreate = DateTime.parse(deadLine);
      Duration difDays = dateCreate.difference(DateTime.now());
      if(difDays.inMinutes > 0){
        if(difDays.inMinutes < 60){
          daysLeft = 'Faltan ${difDays.inMinutes} min';
        }else{
          if(difDays.inHours < 24){
            daysLeft = 'Faltan ${difDays.inHours} horas';
          }else{
            double days = difDays.inHours / 24;
            daysLeft = 'Faltan ${days.toStringAsFixed(0)} días';
          }
        }
      }else{
        if((difDays.inMinutes * -1) < 60){
          daysLeft = 'Hace ${difDays.inMinutes} min';
        }else{
          if((difDays.inHours * -1) < 24){
            daysLeft = 'Hace ${difDays.inHours} horas';
          }else{
            double days = (difDays.inHours * -1) / 24;
            daysLeft = 'Hace ${days.toStringAsFixed(0)} días';
          }
        }
      }
    }
    return daysLeft;
  }

  Widget buscador(){
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: alto * 0.04,
              child: TextFildGeneric(
                onChanged: (text) {
                  if(text.length > 0){
                    iconBuscador = true;
                  }else{
                    iconBuscador = false;
                  }
                  setState(() {});
                },
                labelStyle: textStylePrimary,
                sizeH: alto,
                sizeW: ancho,
                borderColor: WalkieTaskColors.color_E2E2E2,
                sizeBorder: 1.2,
                sizeHeight: alto * 0.045,
                textAlign: TextAlign.left,
                hintText: 'Buscar',
                prefixIcon: InkWell(
                  child: iconBuscador ? Icon(Icons.clear) : Icon(Icons.search),
                  onTap: (){
                    if(iconBuscador){
                      controlleBuscador.text = '';
                      iconBuscador = false;
                      controlleBuscador.clear();
                      FocusScope.of(context).requestFocus(new FocusNode());
                      //WidgetsBinding.instance.addPostFrameCallback((_) => controlleBuscador.clear());
                      setState(() {});
                    }
                  },
                ),
                colorBack: WalkieTaskColors.color_E3E3E3,
                textEditingController: controlleBuscador,
                initialValue: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultSearch(){
    return Container(
      width: ancho,
      height: alto < 600 ? alto * 0.66 : alto * 0.7,
      //color: Colors.amber,
      child: Column(
        children: [
          Container(
            width: ancho,
            height: alto * 0.32,
            //color: Colors.red,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: resultSearchUsers(),
              ),
            ),
          ),
          Container(
            width: ancho,
            color: WalkieTaskColors.color_B7B7B7,
            height: alto * 0.003,
          ),
          Container(
            width: ancho,
            height: alto * 0.32,
            // color: Colors.blue,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: alto * 0.03,),
                Container(
                  width: ancho,
                  margin: EdgeInsets.only(left: ancho * 0.05, right: ancho * 0.1),
                  child: Text('Tareas', style: textStylePrimaryTitleBold,),
                ),
                SizedBox(height: alto * 0.015,),
                Container(
                  height: alto * 0.23,
                  width: ancho,
                  // color: Colors.orange,
                  child: SingleChildScrollView(
                    child: Column(
                      children: resultSearchTask()
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> resultSearchUsers(){
    List<Widget> users = [];

    users.add(SizedBox(height: alto * 0.03,));

    listUser.forEach((user) {

      if(widget.myUserRes.id == null || user.id == widget.myUserRes.id || user.contact == 0) return Container();

      if(!user.name.toLowerCase().contains(controlleBuscador.text.toLowerCase())) return Container();

      Image avatarUser = Image.network(avatarImage);
      if(user.avatar.isNotEmpty){
        avatarUser = Image.network('$directorioImage${user.avatar}');
      }

      bool favorite = user.fijo == 1;

      String dateDiff = 'Sin fecha';
      int cantRecived = 0;
      int cantSend = 0;
      bool redColor = false;
      if(mapDataUserHome[user.id] != null){
        if(mapDataUserHome[user.id][0] != ''){
          dateDiff = getDayDiff(mapDataUserHome[user.id][0]);
          redColor = dateDiff.contains('Hace');
        }
        cantRecived = mapDataUserHome[user.id][1].length;
        cantSend = mapDataUserHome[user.id][2].length;
      }

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
                      redColor ?
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
                              height: alto * 0.02,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: ViewImage().assetsImage("assets/image/icono-fuego.png").image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: ancho * 0.02),
                            Text(dateDiff,style: textStylePrimaryLitleRed,)
                          ],
                        ),
                      )
                          :
                      Text(dateDiff,style: textStylePrimaryLitleBold,),
                      Text('Recibidas: $cantRecived',style: textStylePrimaryLitle,),
                      Text('Enviadas: $cantSend',style: textStylePrimaryLitle,),
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

    if(users.length == 1){
      users.add(
        Container(
          width: ancho,
          margin: EdgeInsets.only(left: ancho * 0.1, right: ancho * 0.1),
          child: Text('No se encontraron resultados', style: textStylePrimary,)
        ),
      );
    }

    users.add(SizedBox(height: alto * 0.03,));

    return users;
  }

  List<Widget> resultSearchTask(){
    List<Widget> tasks = [];

    mapDataUserHome.forEach((key, list) {
      List listAll = [];
      list[1].forEach((task){listAll.add(task);});
      list[2].forEach((task){listAll.add(task);});


      listAll.forEach((task2) {
        Tarea task = task2;
        if(task.name.toLowerCase().contains(controlleBuscador.text.toLowerCase())){

          String nameUser = '';
          if(mapIdUser != null && mapIdUser[task.user_id] != null){
            nameUser = mapIdUser[task.user_id].name;
          }

          String date = '';
          if(task.deadline.isNotEmpty){
            DateTime _dateTime = DateTime.parse(task.deadline);
            date = '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
          }

          tasks.add(
            Container(
              width: ancho,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: ancho * 0.1,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.name, style: textStylePrimaryBold,),
                        Text(nameUser, style: textStylePrimaryLitle,),
                      ],
                    ),
                  ),
                  Container(
                    width: ancho * 0.25,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(date, style: textStylePrimary,),
                        task.url_audio.isNotEmpty ?
                        SoundTask(
                          alto: alto * 0.03,
                          colorStop: WalkieTaskColors.color_E07676,
                          path: task.url_audio,
                        ) : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          tasks.add(
              Container(
                padding: EdgeInsets.only(left: ancho * 0.06, right: ancho * 0.06),
                child: Divider(),
              )
          );
        }
      });
    });

    if(tasks.length == 0){
      tasks.add(
        Container(
            width: ancho,
            margin: EdgeInsets.only(left: ancho * 0.1, right: ancho * 0.1),
            child: Text('No se encontraron resultados', style: textStylePrimary,)
        ),
      );
    }

    tasks.add(SizedBox(height: alto * 0.03,));
    return tasks;
  }
}