import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqliteTask.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/rounded_button.dart';
import 'package:walkietaskv2/utils/textfield_generic.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

class AddNameTask extends StatefulWidget {
  AddNameTask({this.tareaRes});
  final Tarea tareaRes;

  @override
  _AddNameTaskState createState() => _AddNameTaskState();
}

class _AddNameTaskState extends State<AddNameTask> {

  double alto = 0;
  double ancho = 0;
  bool reproduciendo = false;
  bool load = false;

  AudioPlayer audioPlayer;
  StreamSubscription _durationSubscription;
  Duration _duration;

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer();
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      print('$_duration');
    });
    listenerAudio();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    _durationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: ancho,
          child: Text('Nombrar tarea',
            style: WalkieTaskStyles().styleNunitoRegular(size: alto * 0.03, color: WalkieTaskColors.color_969696), textAlign: TextAlign.right,),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(false),
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
      ),
      backgroundColor: WalkieTaskColors.white,
      body: _container(),
    );
  }

  Widget _container(){

    bool isAudio = (widget.tareaRes.url_audio != null && widget.tareaRes.url_audio.isNotEmpty);


    return Center(
      child: Container(
        width: ancho,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Nombrar la tarea', style: WalkieTaskStyles().styleHelveticaNeueBold(size: alto * 0.03,color: WalkieTaskColors.primary),),
            SizedBox(height: alto * 0.01,),
            Text('Así podrás reconocerla entre las demás',style:WalkieTaskStyles().stylePrimary(size: alto * 0.02,spacing: 1.25,color: WalkieTaskColors.color_4D4D4D, fontWeight: FontWeight.bold), ),
            SizedBox(height: alto * 0.03,),
            isAudio ? _sound() : Container(),
            SizedBox(height: alto * 0.03,),
            _tituloTarea()
          ],
        ),
      ),
    );
  }

  String titleTask = '';
  conexionHttp connectionHttp = new conexionHttp();
  Widget _tituloTarea(){
    return Container(
      width: ancho,
      padding: EdgeInsets.only(left: ancho * 0.1,right: ancho * 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Nombre de la tarea:',style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_969696, spacing: 0.5),),
          SizedBox(height: alto * 0.01,),
          Container(
            height: alto * 0.04,
            child: TextFildGeneric(
              onChanged: (text) {
                setState(() {
                  titleTask = text;
                });
              },
              labelStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.color_969696, spacing: 1.5),
              sizeH: alto,
              sizeW: ancho,
              borderColor: WalkieTaskColors.color_E2E2E2,
              sizeBorder: 1.8,
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: alto * 0.01,),
          Container(
            width: ancho,
            child: Align(
              alignment: Alignment.centerRight,
              child: load ?
              Container(
                width: ancho * 0.2,
                child: Center(
                  child: Container(
                    width: alto * 0.035,
                    height: alto * 0.035,
                    child: Center(child: CircularProgressIndicator(),),
                  ),
                ),
              ) :
              RoundedButton(
                backgroundColor: WalkieTaskColors.primary,
                title: 'Aceptar',
                radius: 5.0,
                textStyle: WalkieTaskStyles().stylePrimary(size: alto * 0.02,color: WalkieTaskColors.white,fontWeight: FontWeight.bold,spacing: 1),
                width: ancho * 0.2,
                height: alto * 0.035,
                onPressed: () async {
                  load = true;
                  setState(() {});
                  if(titleTask.isNotEmpty){
                    try{
                      var response = await connectionHttp.httpUpdateNameTask(widget.tareaRes.id, titleTask);
                      var value = jsonDecode(response.body);
                      if(value['status_code'] == 200){
                        await TaskDatabaseProvider.db.updateTaskName(widget.tareaRes.id,titleTask);
                        Navigator.of(context).pop(true);
                        setState(() {});
                      }else{
                        showAlert('Error de conexión',WalkieTaskColors.color_E07676);
                      }
                    }catch(e){
                      print(e.toString());
                      showAlert('Error al enviar datos.',WalkieTaskColors.color_E07676);
                    }
                  }else{
                    showAlert('Se debe agregar un nombre a la tarea.',WalkieTaskColors.color_E07676);
                  }
                  load = false;
                  setState(() {});
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sound(){
    Image imagen  = Image.asset('assets/image/playOpa.png',height: alto * 0.1,fit: BoxFit.contain,);
    if(reproduciendo){
      imagen = Image.asset('assets/image/Pausa.png',height: alto * 0.1,fit: BoxFit.contain,);
    }

    return Container(
      width: ancho,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: imagen,
            onTap: () async {
              if(!reproduciendo){
                audioPlayer.play(widget.tareaRes.url_audio);
              }else{
                await audioPlayer.pause();
              }
              setState(() {
                reproduciendo = !reproduciendo;
              });
            },
          ),
          Container(
            child: Text('$minutos:$segundos',style: WalkieTaskStyles().stylePrimary(size:  alto * 0.026, color: WalkieTaskColors.color_969696),),
          ),
        ],
      ),
    );
  }

  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      print('Current position: $p');
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        setState(() {
          reproduciendo = false;
        });
      }
      if(AudioPlayerState.PAUSED == s){
        //pause = true;
        reproduciendo = false;
        setState(() {});
      }
      if(AudioPlayerState.PLAYING == s){
        if(oldState == AudioPlayerState.COMPLETED){
          _resetSoundPause();
        }
        //pause = false;
        reproduciendo = true;
        setState(() {});
        _contMinutePause();
      }
      oldState = s;
      if(AudioPlayerState.STOPPED == s){
        oldState = AudioPlayerState.COMPLETED;
      }
    });
  }

  void _resetSoundPause(){
    minutos = '00';
    segundos = '00';
    mostrarMinutosEspera = 0;
    segundoEspera = 0;
    reproduciendo = false;
    setState(() {});
  }

  int mostrarMinutosEspera = 0;
  int segundoEspera = 0;
  String minutos = '00';
  String segundos = '00';

  Future<void> _contMinutePause() async {
    if(reproduciendo){
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
      _contMinutePause();
    }
  }
}
