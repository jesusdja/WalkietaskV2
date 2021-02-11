import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';

class ViewImageAttachment2 extends StatefulWidget {
  ViewImageAttachment2({@required this.pathImage, @required this.idMyUser});
  final String pathImage;
  final String idMyUser;

  @override
  _ViewImageAttachmentState createState() => _ViewImageAttachmentState();
}

class _ViewImageAttachmentState extends State<ViewImageAttachment2> {

  String pathImage = '';
  double alto = 0;
  double ancho = 0;

  @override
  void initState() {
    super.initState();
    pathImage = widget.pathImage;
  }

  @override
  Widget build(BuildContext context) {

    ancho = MediaQuery.of(context).size.width;
    alto = MediaQuery.of(context).size.height;

    String nameImage = '';
    if(pathImage != null && pathImage.isNotEmpty){
      nameImage = pathImage.replaceAll('%', '/');
      nameImage = nameImage.split('/').last;
      int pos = nameImage.indexOf('U${widget.idMyUser}');
      nameImage = nameImage.substring(pos + 3, nameImage.length);
    }

    return Scaffold(
      appBar: _appBarH(),
      body: GestureDetector(
        child: Container(
          color: colorFondoChat,
          width: ancho,
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/image/LogoW.png',
            placeholderCacheHeight: 6,
            placeholderCacheWidth: 10,
            image: pathImage,
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }


  Widget _appBarH(){
    return AppBar(
      actions: <Widget>[
        Container(
          margin: EdgeInsets.only(right: ancho * 0.05),
          child: InkWell(
            child: Icon(Icons.download_sharp,size: alto * 0.05, color: WalkieTaskColors.color_969696,),
            onTap: () async{
              Navigator.of(context).pop();
              try{
                if (await canLaunch(pathImage)) {
                  await launch(pathImage);
                } else {
                  throw 'Could not launch $pathImage';
                }
              }catch(e){
                print(e.toString());
                showAlert('Error al descargar imagen, verifique su conexión.',WalkieTaskColors.color_89BD7D);
              }
            },
          ),
        )
      ],
      elevation: 0,
      backgroundColor: colorFondoChat,
      leading: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
        },
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
    );
  }
}

class ViewImageAttachment extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ViewImageAttachment> {
  static double _height = 100, _one = -_height, _two = _height;
  final double _oneFixed = -_height;
  final double _twoFixed = _height;
  Duration _duration = Duration(milliseconds: 5);
  bool _top = false, _bottom = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Slide")),
      body: SizedBox(
        height: _height,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              height: _height,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy >= 0) _toggleTop();
                  else _toggleBottom();
                },
                child: _myContainer(
                  color: Colors.yellow[800],
                  text: "Old Container",
                  child1: IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: _toggleTop,
                  ),
                  child2: IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: _toggleBottom,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: _one,
              height: _height,
              child: GestureDetector(
                //onTap: _toggleTop,
                //onPanEnd: (details) => _toggleTop(),
                onPanUpdate: (details) {
                  _one += details.delta.dy;
                  if (_one >= 0) _one = 0;
                  if (_one <= _oneFixed) _one = _oneFixed;
                  print(_oneFixed);
                  print(_one);
                  if(_one < (-20)){
                    _toggleTop();
                  }
                  setState(() {});
                },
                child: _myContainer(
                  color: _one >= _oneFixed + 1 ? Colors.red[800] : Colors.transparent,
                  text: "Upper Container",
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: _two,
              height: _height,
              child: GestureDetector(
                onTap: _toggleBottom,
                onPanEnd: (details) => _toggleBottom(),
                onPanUpdate: (details) {
                  _two += details.delta.dy;
                  if (_two <= 0) _two = 0;
                  if (_two >= _twoFixed) _two = _twoFixed;
                  setState(() {});
                },
                child: _myContainer(
                  color: _two <= _twoFixed - 1 ? Colors.green[800] : Colors.transparent,
                  text: "Bottom Container",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myContainer({Color color, String text, Widget child1, Widget child2, Function onTap}) {
    Widget child;
    if (child1 == null || child2 == null) {
      child = Text(text, style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold));
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          child1,
          child2,
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  void _toggleTop() {
    _top = !_top;
    Timer.periodic(_duration, (timer) {
      if (_top) _one += 2;
      else _one -= 2;

      if (_one >= 0) {
        _one = 0;
        timer.cancel();
      }
      if (_one <= _oneFixed) {
        _one = _oneFixed;
        timer.cancel();
      }
      setState(() {});
    });
  }

  void _toggleBottom() {
    _bottom = !_bottom;
    Timer.periodic(_duration, (timer) {
      if (_bottom) _two -= 2;
      else _two += 2;

      if (_two <= 0) {
        _two = 0;
        timer.cancel();
      }
      if (_two >= _twoFixed) {
        _two = _twoFixed;
        timer.cancel();
      }
      setState(() {});
    });
  }
}
