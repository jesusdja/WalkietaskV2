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
import 'package:walkietaskv2/utils/Globales.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/view_image.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Tareas/Create/new_task_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';

class BottomDetailsTask extends StatefulWidget {

  final Usuario user;
  final bool isPersonal;
  final List<Caso> listaCasos;
  final BlocProgress blocIndicatorProgress;
  final UpdateData updateData;
  final BlocTask blocTaskSend;
  final BlocTask blocTaskReceived;
  final BlocCasos blocTab;
  bool isTaskProject;
  final Caso projectToCreateTaskForProject;

  BottomDetailsTask({
    @required this.user,
    @required this.isPersonal,
    @required this.listaCasos,
    @required this.blocIndicatorProgress,
    @required this.updateData,
    @required this.blocTaskSend,
    @required this.blocTaskReceived,
    this.blocTab,
    this.isTaskProject = false,
    this.projectToCreateTaskForProject,
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
  FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder();

  UpdateData updateData;

  @override
  void initState() {
    super.initState();
    updateData = widget.updateData;
    pathinicial();
  }

  @override
  void dispose() {
    super.dispose();
    flutterSoundRecorder?.closeAudioSession();
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    user = widget.user;

    textStyleBlue = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.022, color: WalkieTaskColors.primary, spacing: 1, fontWeight: FontWeight.bold);
    textStyleBlueLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.primary, spacing: 0.5, fontWeight: FontWeight.bold);
    textStyleRed = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.024, color: WalkieTaskColors.color_DD7777, spacing: 1, fontWeight: FontWeight.bold);
    textStyleRedLitle = WalkieTaskStyles().styleHelveticaneueRegular(size: alto * 0.016, color: WalkieTaskColors.color_DD7777, spacing: 0.5, fontWeight: FontWeight.bold);

    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.only(left: ancho * 0.02),
      width: ancho,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: grabando ? _textGrabando() :
            Container(
              child: Text('${translate(context: context, text: 'newTask')} ${user.name}:', style: textStyleBlue,maxLines: 2,),
            ),
          ),
          grabando ? Container( height: 20, ) : widget.isTaskProject ? Container( height: 20, ) : _buttonText(),
          _buttonAudio(),
        ],
      ),
    );
  }

  Widget _buttonText(){
    return InkWell(
      onTap: () async {
        widget.blocTab.inList.add(false);
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
        height: alto * 0.08,
        color: Colors.transparent,
        child: Center(
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
                      image: Image.asset("assets/image/Icon_text.png", color: WalkieTaskColors.primary).image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Text(translate(context: context,text: 'text'), style: textStyleBlueLitle,)
              ],
            ),
          ),
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
        widget.blocTab.inList.add(false);
      },
      onTapUp: (va)=> actionGrabando(),
      onHorizontalDragEnd: (d) => actionGrabando(),
      onVerticalDragEnd: (d) => actionGrabando(),
      child: Container(
        height: alto * 0.08,
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: EdgeInsets.only(left: ancho * 0.02, right: ancho * 0.04,),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                grabando ?
                Container(
                  height: alto * 0.03,
                  width: alto * 0.025,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.asset("assets/image/micro_red.png").image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ) :
                Container(
                  height: alto * 0.03,
                  width: alto * 0.025,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Image.asset("assets/image/Icon_microphone_blue.png").image,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Text(translate(context: context,text: 'audio'), style: grabando ? textStyleRedLitle : textStyleBlueLitle,)
              ],
            ),
          ),
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
      audioPath = '$appDocPath/$audioName.mp3';
      await flutterSoundRecorder.startRecorder(toFile: '$appDocPath/$audioName.mp3').then((value) {
        print('startRecorder');
        setState(() {});
      });
      Wakelock.enable();
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  _detenergrabar() async {
    try{
      try{
        await flutterSoundRecorder.stopRecorder().then((value) {
          setState(() {});
        });
        Wakelock.disable();
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
              projectToCreateTaskForProject: widget.projectToCreateTaskForProject,
            )));
        if(result2){
          updateData.actualizarListaEnviados(widget.blocTaskSend, null);
          updateData.actualizarListaRecibidos(widget.blocTaskReceived, null);
          widget.blocTab.inList.add(true);
          if(widget.isTaskProject){
            Navigator.of(context).pop(true);
          }
        }
      }else{
        showAlert(translate(context: context,text: 'noAudio'),WalkieTaskColors.color_E07676);
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
      child: Text('${translate(context: context, text: 'recording')}... $minutos:$segundos', style: textStyleRed,maxLines: 2,),
    );
  }

  Future<void> _contMinute() async {
    if(grabando){
      await Future.delayed(Duration(seconds: 1));
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
      _contMinute();
    }
  }

  pathinicial() async{

    try{
      await flutterSoundRecorder.openAudioSession();
    }catch(e){
      print(e.toString());
    }

    Directory appDocDi25;
    if (!Platform.isAndroid) {
      appDocDi25 = await getApplicationDocumentsDirectory();
    }else{
      appDocDi25 = await getExternalStorageDirectory();
    }
    appDocPath = appDocDi25.path;
    setState(() {});
  }
}
