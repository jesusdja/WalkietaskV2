import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Cargando.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_invitation.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_projects.dart';
import 'package:walkietaskv2/views/binnacle/widgets/binnacle_task.dart';

class BinnaclePage extends StatefulWidget {

  BinnaclePage({ this.myUser });

  final Usuario myUser;

  @override
  _BinnaclePageState createState() => _BinnaclePageState();
}

class _BinnaclePageState extends State<BinnaclePage> {

  double alto = 0;
  double ancho = 0;

  Usuario myUser;
  Image avatarUser;

  bool loadData = true;

  List binnaclesList = [];
  Map<String,List<dynamic>> binnaclesMap = {};

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
        binnaclesList = value['binnacles'] ?? [];
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
        binnaclesList.isEmpty ?
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
      element = BinnacleTask(type: data['type'],info: data,myUser: myUser,);
    }

    if(data['category'] == 'project'){
      element = BinnacleProjects(type: data['type'],info: data,myUser: myUser,);
    }

    if(data['category'] == 'invitation' || data['category'] == 'contact'){
      element = BinnacleInvitation(type: data['type'],info: data,myUser: myUser,);
    }

    return element;
  }
}
