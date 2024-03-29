import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:intl/intl.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Firebase/chatTareasFirebase.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/services/provider/language_provider.dart';
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

class BinnaclePage extends StatefulWidget {

  BinnaclePage({ this.myUser, @required this.blocTaskReceived, @required this.listCase });

  final Usuario myUser;
  final BlocTask blocTaskReceived;
  final List<Caso> listCase;

  @override
  _BinnaclePageState createState() => _BinnaclePageState();
}

class _BinnaclePageState extends State<BinnaclePage> {

  double alto = 0;
  double ancho = 0;

  Usuario myUser;
  Image avatarUser;

  bool loadData = true;

  Map<String,List<dynamic>> binnaclesMap = {};



  Map<int,String> dateMapEs = {
    1 : 'enero',
    2 : 'febrero',
    3 : 'Marzo',
    4 : 'abril',
    5 : 'mayo',
    6 : 'junio',
    7 : 'julio',
    8 : 'agosto',
    9 : 'septiembre',
    10: 'octubre',
    11: 'noviembre',
    12: 'diciembre',
  };

  Map<int,String> dateMapEn = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'may',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  Locale locale = Locale('es');

  CollectionReference taskCollection = FirebaseFirestore.instance.collection('Tareas');
  ChatTareaFirebase chatTaskData = ChatTareaFirebase();

  int page = 1;
  int pageLast = 0;

  @override
  void initState() {
    super.initState();
    myUser = widget.myUser;
    initData();
  }

  Future<void> initData() async {
    avatarUser = await getPhotoUser();
    if(myUser != null){
      if(myUser != null && myUser.avatar_100 != ''){
        avatarUser = Image.network(myUser.avatar_100);
      }
    }
    setState(() {});
    initDataBinnacle();
  }

  Future<void> initDataBinnacle() async {
    try{
      var response = await conexionHttp().httpBinnacle(page);
      var value = jsonDecode(response.body);
      if(value['status_code'] == 200){
        List binnaclesList = value['binnacles']['data'] ?? [];
        page++;
        pageLast = value['binnacles']['last_page'];
        for(int x = 0; x < binnaclesList.length; x++){
          Map<String,dynamic> element = binnaclesList[x];
          if(element['category'] != 'chat'){
            DateTime t = DateTime.parse(element['created_at']);
            String day = t.day >= 10 ? '${t.day}' : '0${t.day}';
            String month = t.month >= 10 ? '${t.month}' : '0${t.month}';
            String f = '${t.year}-$month-$day';
            if(binnaclesMap[f] == null){ binnaclesMap[f] = []; }
            binnaclesMap[f].add(element);
          }

          if(element['category'] == 'chat'){
            String type = 'toUser';
            if(element['user_action_id'].toString() != widget.myUser.id.toString()){ type = 'fromUser'; }

            Map<String,dynamic> listChat = {};
            DateTime time = DateTime.parse(element['created_at']);

            String formattedDate = DateFormat('yyyy-MM-dd').format(time);
            String formattedHours = DateFormat('kk:mm:ss').format(time);

            Tarea taskSms = await DatabaseProvider.db.getCodeIdTask(element['document_id'].toString());

            listChat = {
              'id' : element['id'],
              'category' : 'chat',
              'type' : type,
              'idTarea' : element['document_id'],
              'created_at' : element['created_at'],
              'info' : {
                'fecha': formattedDate,
                'hora': formattedHours,
                'from': element['usernotification']['id'],
                'texto': element['message'] ?? '',
              },
              'task' : taskSms.toMap(),
              'userFrom' : element['usernotification']
            } ;

            if(binnaclesMap[formattedDate] == null){ binnaclesMap[formattedDate] = []; }
            binnaclesMap[formattedDate].add(listChat);
          }
        }
      }else{
        showAlert(translate(context: context, text: 'errorLoadingBinnacle') ?? '', WalkieTaskColors.color_E07676);
      }
    }catch(e){
      print(e.toString());
      showAlert(translate(context: context, text: 'errorLoadingBinnacle') ?? '', WalkieTaskColors.color_E07676);
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
            if(DateTime.parse(listElementForDay2[x]['created_at']).isAfter(DateTime.parse(dateMore))){
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
      showAlert(translate(context: context, text: 'errorSendingInformation') ?? '', WalkieTaskColors.color_E07676);
    }

    loadData = false;
    if(mounted){
      setState(() {});
    }

    if(page <= pageLast){
      initDataBinnacle();
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

    var appLanguage = Provider.of<LanguageProvider>(context);
    locale = appLanguage.appLocal;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: _appBar(),
        body: loadData ?
        Center(
          child: Container(child: Cargando(translate(context: context, text: 'loadingActivityBinnacle'),context),),
        )
        :
        binnaclesMap.isEmpty ?
        Center(
          child: Text(translate(context: context, text: 'noInformation'), style: WalkieTaskStyles().stylePrimary(size: alto * 0.025, spacing: 0.5),),
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

    String userName = myUser != null ? myUser.name ?? '' : '';

    return AppBar(
      title: Container(
        width: ancho,
        child: Text(translate(context: context, text: 'activityLog'),
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
          child: avatarUser != null ?
          CircleAvatar(
            radius: alto * 0.025,
            backgroundImage: avatarUser.image,
          ) : avatarWidget(alto: alto,text: userName.isEmpty ? '' : userName.substring(0,1).toUpperCase(),radius: 0.025),
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
      String title = locale == Locale('es') ? '${date.day} de ${dateMapEs[date.month]}, ${date.year}' : '${dateMapEn[date.month]} ${date.day}, ${date.year}';
      if(date.difference(DateTime.now()).inDays == 0){
        title = '${translate(context: context, text: 'today')} ($title)';
      }
      if(date.difference(DateTime.now()).inDays == (-1)){
        title = '${translate(context: context, text: 'yesterday')} ($title)';
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
            clickTask(Tarea.fromMap(data['info']), false, {});
          }else{
            showAlert('${translate(context: context, text: 'openDeletedTask')}.', WalkieTaskColors.color_E07676);
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
          print('');
          if(data['task'] != null){
            clickTask(Tarea.fromMap(data['task']), true, data);
          }
        },
        child: BinnacleChat(type: data['type'],info: data,myUser: myUser,),
      );
    }

    return element;
  }

  void clickTask(Tarea tarea, bool isChat, Map<String,dynamic> chat) async {

    readTask(tarea);

    try{
      if(tarea.name.isEmpty){
        var result  = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
        if(result){
          widget.blocTaskReceived.inList.add(true);
        }
      }else{
        await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new ChatForTarea(
              tareaRes: tarea,
              listaCasosRes: widget.listCase,
              blocTaskSend: widget.blocTaskReceived,
              isChat: isChat,
              chat: chat,
            )));
        loadData = true;
        if(mounted){
          setState(() {});
        }
        initDataBinnacle();
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
