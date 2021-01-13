import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';

class SoundTask extends StatefulWidget {

  final bool status;
  final double alto;
  final Color colorPlay;
  final Color colorStop;
  final String path;

  SoundTask({
    this.status = false,
    this.alto = 30,
    this.colorPlay = WalkieTaskColors.color_555555,
    this.colorStop = WalkieTaskColors.color_555555,
    this.path = '',
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
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
      print('$_duration');
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
          if(!sonando){
            audioPlayer.play(widget.path);
          }else{
            await audioPlayer.stop();
          }
          setState(() {
            sonando = !sonando;
          });
        }else{
          showAlert('Problemas para reproducir audio.',WalkieTaskColors.color_E07676);
        }
      },
      child: Container(
        width: ancho * 0.15,
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
      print('Current position: $p');
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      print('Current player state: $s');
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
        setState(() {
          sonando = false;
        });
      }
    });
  }
}
