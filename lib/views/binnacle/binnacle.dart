import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Chat/ChatTareas.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_chat.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_invitation.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_projects.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_task.dart';

class BinnaclePage2 extends StatefulWidget {

  BinnaclePage2({ this.myUser, @required this.blocTaskReceived, @required this.listCase });

  final Usuario myUser;
  final BlocTask blocTaskReceived;
  final List<Caso> listCase;

  @override
  _BinnaclePageState createState() => _BinnaclePageState();
}

class _BinnaclePageState extends State<BinnaclePage2> {

  double alto = 0;
  double ancho = 0;

  Usuario myUser;
  Image avatarUser;

  bool loadData = true;

  Map<String,List<dynamic>> binnaclesMap = {};

  List<Map<String,dynamic>> listChat = [];

  Map<int,String> dateMap = {
    1 : 'enero',
    2 : 'febrero',
    3 : 'Marzo',
    4 : 'abril',
    5 : 'mayo',
    6 : 'junio',
    7 : 'julio',
    8 : 'agosto',
    9 : 'septiembre',
    10 : 'octubre',
    11 : 'noviembre',
    12: 'diciembre',
  };

  CollectionReference taskCollection = FirebaseFirestore.instance.collection('Tareas');
  ChatTareaFirebase chatTaskData = ChatTareaFirebase();

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
    initData();
    initDataBinnacle();
  }

  Future<void> initData() async {
    avatarUser = await getPhotoUser();
    avatarUser = avatarUser ?? Image.network(avatarImage);
    if(myUser != null){
      if(myUser != null && myUser.avatar_100 != ''){
        avatarUser = Image.network(myUser.avatar_100);
      }
    }
    setState(() {});
  }

  Future<void> initDataBinnacle() async {
    try{
      var response = await conexionHttp().httpBinnacle();
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        List binnaclesList = value['binnacles'] ?? [];
        binnaclesList.forEach((element) {
          DateTime t = DateTime.parse(element['created_at']);
          String day = t.day >= 10 ? '${t.day}' : '0${t.day}';
          String month = t.month >= 10 ? '${t.month}' : '0${t.month}';
          String f = '${t.year}-$month-$day';
          if(binnaclesMap[f] == null){ binnaclesMap[f] = []; }
          binnaclesMap[f].add(element);
        });
      }else{
        showAlert('Error al obtener datos de bitácora', WalkieTaskColors.color_E07676);
      }
    }catch(e){
      print(e.toString());
      showAlert('Error al obtener datos de bitácora', WalkieTaskColors.color_E07676);
    }

    //CARGAR DATA FIREBASE
    try{
      List<ChatTareas> listChatToUser = await chatTaskData.getChatForUser(myUser.id.toString());
      List<ChatTareas> listChatFromUSer = await chatTaskData.getChatForUserFrom(myUser.id.toString());

      listChatToUser.forEach((element) {
        element.mensajes.forEach((key,value){
          String type = 'toUser';
          if(value['from'] != widget.myUser.id.toString()){ type = 'fromUser'; }
          listChat.add( { 'id' : element.id, 'category' : 'chat', 'type' : type, 'idTarea' : element.idTarea, 'created_at' : '${value['fecha']} ${value['hora']}', 'info' : value , 'task' : element.task, 'userFrom' : element.userFrom} );
        });
      });

      listChatFromUSer.forEach((element) {
        element.mensajes.forEach((key,value){
          String type = 'toUser';
          if(value['from'] != widget.myUser.id.toString()){ type = 'fromUser'; }
          listChat.add( { 'id' : element.id, 'category' : 'chat', 'type' : type, 'idTarea' : element.idTarea, 'created_at' : '${value['fecha']} ${value['hora']}', 'info' : value, 'task' : element.task, 'userFrom' : element.userFrom } );
        });
      });

      listChat.forEach((elementChat) {
        DateTime t = DateTime.parse(elementChat['created_at']);
        String day = t.day >= 10 ? '${t.day}' : '0${t.day}';
        String month = t.month >= 10 ? '${t.month}' : '0${t.month}';
        String f = '${t.year}-$month-$day';
        if(binnaclesMap[f] == null){ binnaclesMap[f] = []; }
        binnaclesMap[f].add(elementChat);
      });

    }catch(e){
      print(e.toString());
      showAlert('Error al obtener datos del chat', WalkieTaskColors.color_E07676);
    }


    //ORDENAR LAS LISTAS POR FECHA
    try{
      Map binnaclesMap2 = {};
      binnaclesMap.forEach((key, value) { binnaclesMap2[key] = value; });

      binnaclesMap2.forEach((key, listElementForDay) {
        List listElementForDay2 = listElementForDay.map((e) => e).toList();
        List finalList = [];
        listElementForDay.forEach((element) {
          int pos = 0;
          String dateMore = listElementForDay2[0]['created_at'];
          for(int x = 0; x < listElementForDay2.length; x++){
            Duration diff1 = DateTime.parse(dateMore).difference(DateTime.now());
            Duration diff2 = DateTime.parse(listElementForDay2[x]['created_at']).difference(DateTime.now());
            if(diff2 > diff1){
              dateMore = listElementForDay2[x]['created_at'];
              pos = x;
            }
          }
          finalList.add(listElementForDay2[pos]);
          listElementForDay2.removeAt(pos);
        });
        binnaclesMap[key] = finalList;
      });
    }catch(e){
      print(e.toString());
      showAlert('Error al obtener datos del chat', WalkieTaskColors.color_E07676);
    }

    loadData = false;
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    List<Widget> data1 = _data();
    List<Widget> data2 = [];

    for(int x = data1.length; x > 0; x--){
      data2.add(data1[x - 1]);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: _appBar(),
        body: loadData ?
        Center(
          child: Container(child: Cargando('Cargando bitácora',context),),
        )
        :
        binnaclesMap.isEmpty ?
        Center(
          child: Text('Sin datos en la bitácora.', style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, spacing: 0.5),),
        ) :
        Container(
          child: ListView.builder(
            itemCount: data2.length,
            reverse: true,
            itemBuilder: (context, i){
              return data2[i];
            },
          ),
        )
      ),
    );
  }

  Widget _appBar(){
    return AppBar(
      title: Container(
        width: ancho,
        child: Text('Bitácora de actividades',
          style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.025, color: WalkieTaskColors.color_3C3C3C),textAlign: TextAlign.left,),
      ),
      elevation: 0,
      backgroundColor: Colors.grey[100],
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,color: WalkieTaskColors.primary, size: alto * 0.04,),
        onPressed: () async {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: ancho * 0.02),
          child: avatarUser != null ? CircleAvatar(
            radius: alto * 0.025,
            backgroundImage: avatarUser.image,
          ) : CircleAvatar(
            radius: alto * 0.025,
            backgroundColor: WalkieTaskColors.color_B7B7B7,
          ),
        )
      ],
    );
  }

  List<Widget> _data(){
    List<Widget> data = [];

    //ORDENAR MAPA DE FECHAS
    List listOrderTitle = [];
    List listOrder = [];
    List listOrder2 = [];
    binnaclesMap.forEach((keyDate, value){
      listOrder.add(keyDate);
      listOrder2.add(keyDate);
    });


    listOrder.forEach((element) {
      int pos = 0;
      String dateMore = listOrder2[0];
      for(int x = 0; x < listOrder2.length; x++){
        Duration diff1 = DateTime.parse(dateMore).difference(DateTime.now());
        Duration diff2 = DateTime.parse(listOrder2[x]).difference(DateTime.now());
        if(diff2 < diff1){
          dateMore = listOrder2[x];
          pos = x;
        }
      }
      listOrderTitle.add(listOrder2[pos]);
      listOrder2.removeAt(pos);
    });

    //MOSTRAR TITUTLOS CON SUS COLUMNAS
    listOrderTitle.forEach((keyDate) {
      List value = binnaclesMap[keyDate];

      DateTime date = DateTime.parse(keyDate);
      String title = '${date.day} de ${dateMap[date.month]}, ${date.year}';
      if(date.difference(DateTime.now()).inDays == 0){
        title = 'Hoy ($title)';
      }
      if(date.difference(DateTime.now()).inDays == (-1)){
        title = 'Ayer ($title)';
      }

      List elementDay = [];
      List values = value.map((e) => e).toList();
      List values2 = value.map((e) => e).toList();

      values.forEach((element) {
        int pos = 0;
        String dateMore = values2[0]['created_at'];
        for(int x = 0; x < values2.length; x++){
          Duration diff1 = DateTime.parse(dateMore).difference(DateTime.now());
          Duration diff2 = DateTime.parse(element['created_at']).difference(DateTime.now());
          if(diff2 > diff1){
            dateMore = element['created_at'];
            pos = x;
          }
        }
        elementDay.add(values2[pos]);
        values2.removeAt(pos);
      });

      List<Widget> columnElementsDay = [];
      List<Widget> columnElementsDay2 = [];

      elementDay.forEach((element) {
        columnElementsDay2.add(elementColumn(element));
      });

      for(int x = columnElementsDay2.length; x > 0; x--){
        columnElementsDay.add(
            Container(
              height: 0.5,
              width: ancho,
              color: WalkieTaskColors.color_969696,
              margin: EdgeInsets.only(bottom: alto * 0.02, top: alto * 0.01),
            )
        );
        columnElementsDay.add(columnElementsDay2[x - 1]);
      }

      data.add(
        Container(
          width: ancho,
          margin: EdgeInsets.symmetric(horizontal: ancho * 0.06),
          child: Column(
            children: [
              Container(
                width: ancho,
                margin: EdgeInsets.symmetric(vertical: alto * 0.02),
                child: Text(title,style: WalkieTaskStyles().stylePrimary(size: alto * 0.022, color: WalkieTaskColors.primary,fontWeight: FontWeight.bold, spacing: 0.5),textAlign: TextAlign.left,),
              ),
              Column(
                children: columnElementsDay,
              )
            ],
          ),
        )
      );
      data.add(
          SizedBox(height: alto * 0.02,)
      );
      data.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: ancho * 0.06, vertical: alto * 0.005),
            height: 0.5,
            width: ancho,
            color: WalkieTaskColors.color_969696,
          )
      );
      data.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: ancho * 0.06),
            height: 0.5,
            width: ancho,
            color: WalkieTaskColors.color_969696,
          )
      );
    });

    return data;
  }

  Widget elementColumn(Map<String, dynamic> data){
    Widget element = Container(
      //child: Text('${data['category']} - ${data['type']}'),
    );

    if(data['category'] == 'task'){
      element = InkWell(
        onTap: () {
          if(data['type'] != 'deleted'){
            clickTask(Tarea.fromMap(data['info']), false, '');
          }else{
            showAlert('No se puede abrir una tarea eliminada.', WalkieTaskColors.color_E07676);
          }
        },
        child: BinnacleTask(type: data['type'],info: data,myUser: myUser,),
      );
    }

    if(data['category'] == 'project'){
      element = BinnacleProjects(type: data['type'],info: data,myUser: myUser,);
    }

    if(data['category'] == 'invitation' || data['category'] == 'contact'){
      element = BinnacleInvitation(type: data['type'],info: data,myUser: myUser,);
    }

    if(data['category'] == 'chat'){
      element = InkWell(
        onTap: (){
          if(data['task'] != null){
            clickTask(Tarea.fromMap(data['task']), true, data['info']['texto']);
          }
        },
        child: BinnacleChat(type: data['type'],info: data,myUser: myUser,),
      );
    }

    return element;
  }

  void clickTask(Tarea tarea, bool isChat, String textChat) async {

    readTask(tarea);

    try{
      if(tarea.name.isEmpty){
        var result  = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
        if(result){
          widget.blocTaskReceived.inList.add(true);
        }
      }else{
        Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ChatForTarea(
              tareaRes: tarea,
              listaCasosRes: widget.listCase,
              blocTaskSend: widget.blocTaskReceived,
            )));
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> readTask(Tarea task) async {

    //CAMBIAR ESTADO DE DESTACAR 0 = FALSE, 1 = TRUE
    if(task.read == 0){
      task.read = 1;
      if(await DatabaseProvider.db.updateTask(task) == 1){
        widget.blocTaskReceived.inList.add(true);
        try{
          await conexionHttp().httpReadTask(task.id);
        }catch(_){}
      }
    }
  }
}

class BinnaclePage extends StatefulWidget {

  BinnaclePage({ this.myUser, @required this.blocTaskReceived, @required this.listCase });

  final Usuario myUser;
  final BlocTask blocTaskReceived;
  final List<Caso> listCase;

  @override
  _MyApp4State createState() => _MyApp4State();
}

class _MyApp4State extends State<BinnaclePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: Home()),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ListPage();
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(80.0),
          child: Text("Click me"),
        ));
  }
}

class ListPage extends StatelessWidget {
  ListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("List"),
        ),
        body: Body());
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  _BodyState();

  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          var position = itemPositionsListener.itemPositions.value.first.index;
          print(position);
          //trigger leaving and use own data
          Navigator.pop(context, false);

          //we need to return a future
          return Future.value(false);
        },
        child: ScrollablePositionedList.builder(
            initialScrollIndex: 400,
            itemPositionsListener: itemPositionsListener,
            itemCount: 500,
            reverse: true,
            itemBuilder: (context, index) => Text('Item $index')));
  }
}
