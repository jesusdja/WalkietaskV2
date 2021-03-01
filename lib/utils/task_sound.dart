import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocProgress.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';

class SoundTask extends StatefulWidget {

  final bool status;
  final double alto;
  final Color colorPlay;
  final Color colorStop;
  final String path;
  final int idTask;
  final BlocProgress blocAudioChangePage;
  final bottonSelect page;
  final Widget textDate;
  final Widget chatCont;

  SoundTask({
    this.status = false,
    this.alto = 30,
    this.colorPlay = WalkieTaskColors.color_555555,
    this.colorStop = WalkieTaskColors.color_555555,
    this.path = '',
    @required this.idTask,
    @required this.blocAudioChangePage,
    @required this.page,
    this.textDate,
    this.chatCont,
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
  StreamSubscription streamSubscriptionPageAudio;
  StreamSubscription _activeAudioSubscription;

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
    _inicializarPatronBloc();
  }

  @override
  void dispose() {
    super.dispose();
    try{
      if(AudioPlayerState.PLAYING == audioPlayer.state){
        audioPlayer?.stop();
      }
      _durationSubscription?.cancel();
      streamSubscriptionPageAudio?.cancel();
      _activeAudioSubscription?.cancel();
    }catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    alto = MediaQuery.of(context).size.height;
    ancho = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () => _onTap(),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(height: alto * 0.006,),
            Container(
              margin: EdgeInsets.only(right: ancho * 0.03),
              child: widget.textDate ?? Container(),
            ),
            SizedBox(height: alto * 0.006,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                widget.chatCont ?? Container(),
                widget.path.isNotEmpty ?
                Container(
                  width: ancho * 0.1,
                  child: Icon(
                    sonando ? Icons.stop : Icons.volume_up,
                    color: sonando ? widget.colorStop : widget.colorPlay,
                    size: widget.alto,
                  ),
                ) : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    try{
      if(widget.path.isNotEmpty){
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
      }
    }catch(e){
      print(e.toString());
      showAlert('Problemas para reproducir audio.',WalkieTaskColors.color_E07676);
    }
  }

  Future<void> listenerAudio() async {
    audioPlayer.onAudioPositionChanged.listen((Duration  p){
      //print('Current position: $p');
    });
    AudioPlayerState oldState = AudioPlayerState.COMPLETED;
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s){
      if(mounted){
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
      }
    });
  }

  _inicializarPatronBloc(){
    try {
      // ignore: cancel_subscriptions
      streamSubscriptionPageAudio = widget.blocAudioChangePage.outList.listen((newVal) {
        if(newVal['page'] != widget.page && audioPlayer.state != null){
          audioPlayer.stop();
          sonando = false;
          setState(() {});
        }
      });
    } catch (e) {}
  }
}
