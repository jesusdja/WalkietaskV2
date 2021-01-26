import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

class SoundTask extends StatefulWidget {

  final bool status;
  final double alto;
  final Color colorPlay;
  final Color colorStop;
  final String path;
  final int idTask;

  SoundTask({
    this.status = false,
    this.alto = 30,
    this.colorPlay = WalkieTaskColors.color_555555,
    this.colorStop = WalkieTaskColors.color_555555,
    this.path = '',
    @required this.idTask,
  });

  @override
  _SoundTaskState createState() => _SoundTaskState();
}

class _SoundTaskState extends State<SoundTask> {

  bool sonando = false;
  double alto = 0;
  double ancho = 0;

  AudioPlayer audioPlayer;
  StreamSubscription _durationSubscription;
  Duration _duration;

  @override
  void initState() {
    super.initState();
    audioPlayer = new AudioPlayer();
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) async {
      //print('$_duration');
      try{
        int idSound = await SharedPrefe().getValue('idSoundWalkie');
        if(idSound != null &&  idSound != widget.idTask && audioPlayer.state == AudioPlayerState.PLAYING){
          audioPlayer.stop();
          setState(() {
            sonando = false;
          });
        }
      }catch(_){}
    });
    listenerAudio();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer?.dispose();
    _durationSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () async {
        if(widget.path.isNotEmpty){
          print('Sonando = $sonando');
          if(!sonando){
            audioPlayer.play(widget.path);
            await SharedPrefe().setIntValue('idSoundWalkie',widget.idTask);
          }else{
            await audioPlayer.stop();
            await SharedPrefe().setIntValue('idSoundWalkie',0);
          }
          setState(() {
            sonando = !sonando;
          });
        }else{
          showAlert('Problemas para reproducir audio.',WalkieTaskColors.color_E07676);
        }
      },
      child: Container(
        width: ancho * 0.1,
        child: Icon(
          sonando ? Icons.stop : Icons.volume_up,
          color: sonando ? widget.colorStop : widget.colorPlay,
          size: widget.alto,
        ),
      ),
    );
  }

  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      //print('Current position: $p');
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      //print('Current player state: $s');
      if(AudioPlayerState.COMPLETED == s){
        setState(() {
          sonando = false;
        });
      }
      if(AudioPlayerState.PLAYING == s){
        sonando = true;
        setState(() {});
      }
      oldState = s;
      if(AudioPlayerState.STOPPED == s){
        oldState = AudioPlayerState.COMPLETED;
      }
    });
  }
}
