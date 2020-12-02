import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
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
            !isAudio ? _sound() : Container(),
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
                        titleTask = '';
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
        children: <Widget>[
          InkWell(
            child: imagen,
            onTap: (){
              setState(() {
                reproduciendo = !reproduciendo;
              });
            },
          ),
        ],
      ),
    );
  }
}
