import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/Create/new_task_user.dart';
import 'package:path_provider/path_provider.dart';

class BottomDetailsTask extends StatefulWidget {

  final Usuario user;
  final bool isPersonal;
  final List<Caso> listaCasos;
  final BlocProgress blocIndicatorProgress;
  final UpdateData updateData;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocCasos blocTab;

  BottomDetailsTask({
    @required this.user,
    @required this.isPersonal,
    @required this.listaCasos,
    @required this.blocIndicatorProgress,
    @required this.updateData,
    @required this.blocTaskSend,
    @required this.blocTaskReceived,
    this.blocTab,
  });

  @override
  _BottomDetailsTaskState createState() => _BottomDetailsTaskState();
}

class _BottomDetailsTaskState extends State<BottomDetailsTask> {

  double alto = 0;
  double ancho = 0;

  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;

  String minutos = '00';
  String segundos = '00';
  String audioName = 'audioplay';
  String audioPath = '';
  String appDocPath = '';

  bool grabando = false;

  TextStyle textStyleBlue;
  TextStyle textStyleBlueLitle;
  TextStyle textStyleRed;
  TextStyle textStyleRedLitle;

  Usuario user;

  FlutterSound flutterSound = new FlutterSound();

  UpdateData updateData;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    updateData = widget.updateData;
    pathinicial();
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    textStyleBlue = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.primary, spacing: 1, fontWeight: FontWeight.bold);
    textStyleBlueLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.primary, spacing: 0.5, fontWeight: FontWeight.bold);
    textStyleRed = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.color_DD7777, spacing: 1, fontWeight: FontWeight.bold);
    textStyleRedLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.color_DD7777, spacing: 0.5, fontWeight: FontWeight.bold);

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.only(top: alto * 0.01, bottom: alto * 0.01, left: ancho * 0.02, right: ancho * 0.04),
      width: ancho,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: grabando ? _textGrabando() :
            Container(
              child: Text('Nueva tarea para ${user.name}:', style: textStyleBlue,maxLines: 2,),
            ),
          ),
          grabando ? Container( height: 20, ) : _buttonText(),
          _buttonAudio(),
        ],
      ),
    );
  }

  Widget _buttonText(){
    return InkWell(
      onTap: () async {
        var result = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new NewTaskForUser(
              user: user,
              isPersonal: widget.isPersonal,
              pathAudio: '',
              listaCasos: widget.listaCasos,
              blocIndicatorProgress: widget.blocIndicatorProgress,
              mapMinSeg: {},
            )));
        if(result){
          updateData.actualizarListaEnviados(widget.blocTaskSend, null);
          updateData.actualizarListaRecibidos(widget.blocTaskReceived, null);
          widget.blocTab.inList.add(true);
        }
      },
      child: Container(
        margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: alto * 0.03,
              width: alto * 0.025,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/Icon_text.png", color: WalkieTaskColors.primary).image,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Text('Texto', style: textStyleBlueLitle,)
          ],
        ),
      ),
    );
  }

  Widget _buttonAudio(){
    return GestureDetector(
      onTapDown: (va) {
        grabando = true;
        setState(() {});
        _grabarSound();
        _contMinute();
      },
      onTapUp: (va)=> actionGrabando(),
      onHorizontalDragEnd: (d) => actionGrabando(),
      onVerticalDragEnd: (d) => actionGrabando(),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            grabando ?
            Container(
              height: alto * 0.03,
              width: alto * 0.025,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/micro_red.png",).image,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ) :
            Container(
              height: alto * 0.03,
              width: alto * 0.025,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ViewImage().assetsImage("assets/image/Icon_microphone_blue.png",).image,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Text('Audio', style: grabando ? textStyleRedLitle : textStyleBlueLitle,)
          ],
        ),
      ),
    );
  }

  actionGrabando(){
    grabando = false;
    setState(() {});
    _detenergrabar();
  }

  _grabarSound() async {
    try {
      DateTime date = DateTime.now();
      audioName = 'audioplay${date.year}${date.month}${date.day}${date.hour}${date.minute}${date.second}';
      audioPath = '$appDocPath/$audioName.mp4';
      String path = await flutterSound.startRecorder('$appDocPath/$audioName.mp4');
      print('startRecorder: $path');
      setState(() {});
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  _detenergrabar() async {
    try{
      String result = '';
      try{
        result = await flutterSound.stopRecorder();
      }catch(ex){
        print('ERROR EN STOP ${ex.toString()}');
      }

      if(segundoEspera >= 3){
        bool exit = audioPath != null ? await File(audioPath).exists() : false;
        print('Audio = $exit');

        int m = mostrarMinutosEspera;
        int s = segundoEspera;
        String ms = minutos;
        String ss = segundos;
        String path = audioPath;

        var result2 = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) =>
            new NewTaskForUser(
              user: user,
              isPersonal: widget.isPersonal,
              pathAudio: path,
              listaCasos: widget.listaCasos,
              blocIndicatorProgress: widget.blocIndicatorProgress,
              mapMinSeg: {
                'minutos' : ms,
                'segundos' : ss,
                'mostrarMinutosEspera' : m,
                'segundoEspera' : s,
              },
            )));
        if(result2){
          updateData.actualizarListaEnviados(widget.blocTaskSend, null);
          updateData.actualizarListaRecibidos(widget.blocTaskReceived, null);
          widget.blocTab.inList.add(true);
        }
      }else{
        showAlert('El mensaje es muy corto o no contiene audio.',WalkieTaskColors.color_E07676);
      }

      minutos = '00';
      segundos = '00';
      mostrarMinutosEspera = 0;
      segundoEspera = 0;
      audioName = 'audioplay';
      audioPath = '';
      setState(() {});
    }catch(e){
      print('detenergrabar error: $e');
    }
  }

  Widget _textGrabando(){
    return Container(
      child: Text('Grabando ... $minutos:$segundos', style: textStyleRed,maxLines: 2,),
    );
  }

  Future<void> _contMinute() async {
    if(grabando){
      segundoEspera++;
      if(segundoEspera > 59){
        mostrarMinutosEspera++;
      }

      minutos = mostrarMinutosEspera.toString();
      segundos = segundoEspera.toString();

      if(mostrarMinutosEspera < 10){
        minutos = '0$minutos';
      }
      if(segundoEspera < 10){
        segundos = '0$segundos';
      }
      setState((){});
      await Future.delayed(Duration(seconds: 1));
      _contMinute();
    }
  }

  pathinicial() async{
    Directory appDocDi25 = await getExternalStorageDirectory();
    appDocPath = appDocDi25.path;
    setState(() {});
  }
}
