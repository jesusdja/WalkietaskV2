import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:walkietaskv2/bloc/blocCasos.dart';
import 'package:walkietaskv2/bloc/blocTareas.dart';
import 'package:walkietaskv2/models/Caso.dart';
import 'package:walkietaskv2/models/Tarea.dart';
import 'package:walkietaskv2/models/Usuario.dart';
import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/flushbar_notification.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';
import 'package:walkietaskv2/views/Chat/ChatForTarea.dart';
import 'package:walkietaskv2/views/Tareas/add_name_task.dart';

void viewNotiLocal({
  @required Tarea task, @required String subTitle, @required String sms,
  @required bool isOnTap, @required Usuario myUser,
  @required String avatarImage, @required Map<int,Usuario> mapIdUser,
  @required double ancho, @required double alto, @required BuildContext context,
  @required BlocTask blocTaskSend, @required List<Caso> listaCasos}){
  bool isRecived = true;
  if(myUser.id == task.user_id){
    isRecived = false;
  }

  Image avatarUser = Image.network(avatarImage);
  String nameUser = '';
  if(isRecived){
    if(mapIdUser[task.user_id] != null){
      if(mapIdUser[task.user_id].avatar_100 != ''){
        avatarUser = Image.network(mapIdUser[task.user_id].avatar_100);
      }
      nameUser = mapIdUser[task.user_id].name;
    }
  }else{
    if(mapIdUser[task.user_responsability_id] != null){
      if(mapIdUser[task.user_responsability_id].avatar_100 != ''){
        avatarUser = Image.network(mapIdUser[task.user_responsability_id].avatar_100);
      }
      nameUser = mapIdUser[task.user_responsability_id].name;
    }
  }

  Widget imageAvatar = Container(
    margin: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
    padding: const EdgeInsets.all(1.5), // borde width
    decoration: new BoxDecoration(
      color: WalkieTaskColors.primary, // border color
      shape: BoxShape.circle,
    ),
    child: CircleAvatar(
      radius: alto * 0.025,
      backgroundImage: avatarUser.image,
    ),
  );
  Widget messageText = Container(
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: subTitle, style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, fontWeight: FontWeight.bold, color: WalkieTaskColors.yellow, spacing: 0.5),),
        TextSpan(text: sms,style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, color: WalkieTaskColors.white, spacing: 0.5)),
      ]),
    ),
  );
  Widget titleText = Container(
    child: Text(nameUser,style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.white, spacing: 0.5, fontWeight: FontWeight.bold),),
  );
  flushBarNotification(
      context: context,
      avatar: imageAvatar,
      titleText: titleText,
      messageText: messageText,
      onTap: (flushbar) {
        if(isOnTap){
          clickTareaNotiLocal(tarea: task, context: context, blocTaskSend: blocTaskSend, listaCasos: listaCasos);
        }
      }
  );
}

Future<void> viewNotiLocalProjects({
  @required String subTitle, @required String idProjects, @required String avatarImage,
  @required Map<int,Usuario> mapIdUser, @required double ancho, @required double alto,
  @required BuildContext context,
}) async {

  Image avatarUser = Image.network(avatarImage);
  String nameUser = '';
  int idUser = 0;
  String nameProyects = '';

  try{
    var response = await conexionHttp().httpGetListGuestsForProjects();
    var value = jsonDecode(response.body);
    if(value['status_code'] == 200){
      if(value['projects'] != null){
        List listHttp = value['projects'];
        listHttp.forEach((element) {
          if(element['id'].toString() ==  idProjects){
            nameProyects = element['name'];
            idUser = element['user_id'];
          }
        });
      }
    }
  }catch(e){}

  if(mapIdUser[idUser] != null){
    if(mapIdUser[idUser].avatar_100 != ''){
      avatarUser = Image.network(mapIdUser[idUser].avatar_100);
    }
    nameUser = mapIdUser[idUser].name;
  }

  Widget imageAvatar = Container(
    margin: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
    padding: const EdgeInsets.all(1.5), // borde width
    decoration: new BoxDecoration(
      color: WalkieTaskColors.primary, // border color
      shape: BoxShape.circle,
    ),
    child: CircleAvatar(
      radius: alto * 0.025,
      backgroundImage: avatarUser.image,
    ),
  );
  Widget messageText = Container(
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: subTitle, style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, fontWeight: FontWeight.bold, color: WalkieTaskColors.yellow, spacing: 0.5),),
        TextSpan(text: nameProyects,style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, color: WalkieTaskColors.white, spacing: 0.5)),
      ]),
    ),
  );
  Widget titleText = Container(
    child: Text(nameUser,style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.white, spacing: 0.5, fontWeight: FontWeight.bold),),
  );
  flushBarNotification(
      context: context,
      avatar: imageAvatar,
      titleText: titleText,
      messageText: messageText,
      onTap: (flushbar) {}
  );
}

Future<void> viewNotiLocalPersonal({
  @required String title, @required String subTitle, String description,@required String avatarImage,
  @required Map<int,Usuario> mapIdUser, @required double ancho, @required double alto,
  @required BuildContext context, @required Usuario myUser,
}) async {

  Image avatarUser = Image.network(avatarImage);
  if(myUser != null){
    if(myUser.avatar_100 != ''){
      avatarUser = Image.network(myUser.avatar_100);
    }
  }

  Widget imageAvatar = Container(
    margin: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
    padding: const EdgeInsets.all(1.5), // borde width
    decoration: new BoxDecoration(
      color: WalkieTaskColors.primary, // border color
      shape: BoxShape.circle,
    ),
    child: CircleAvatar(
      radius: alto * 0.025,
      backgroundImage: avatarUser.image,
    ),
  );
  Widget titleText = Container(
    child: Text(title,style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.white, spacing: 0.5, fontWeight: FontWeight.bold),),
  );
  Widget messageText = Container(
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: subTitle, style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, fontWeight: FontWeight.bold, color: WalkieTaskColors.yellow, spacing: 0.5),),
        TextSpan(text: description,style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, color: WalkieTaskColors.white, spacing: 0.5)),
      ]),
    ),
  );
  flushBarNotification(
      context: context,
      avatar: imageAvatar,
      titleText: titleText,
      messageText: messageText,
      onTap: (flushbar) {}
  );
}

void clickTareaNotiLocal({@required Tarea tarea, @required BuildContext context,
  @required BlocTask blocTaskSend, @required List<Caso> listaCasos}) async {
  try{
    if(tarea.name.isEmpty){
      var result  = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new AddNameTask(tareaRes: tarea,)));
      if(result){
        blocTaskSend.inList.add(true);
      }
    }else{
      Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) =>
          new ChatForTarea(
            tareaRes: tarea,
            listaCasosRes: listaCasos,
            blocTaskSend: blocTaskSend,
          )));
    }
  }catch(e){
    print(e.toString());
  }
}

void errorUploadImage({
  @required double ancho, @required double alto, @required BuildContext context,
  String title = '', String subtitle = '', String sms = '',
}){
  Widget imageAvatar = Container(
    margin: EdgeInsets.only(left: ancho * 0.01, right: ancho * 0.01),
    padding: const EdgeInsets.all(1.5), // borde width
    decoration: new BoxDecoration(
      color: WalkieTaskColors.primary, // border color
      shape: BoxShape.circle,
    ),
    child: CircleAvatar(
      radius: alto * 0.025,
      child: Center(
        child: Icon(Icons.cancel_outlined),
      ),
    ),
  );
  Widget messageText = Container(
    child: RichText(
      text: TextSpan(children: [
        TextSpan(text: subtitle, style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, fontWeight: FontWeight.bold, color: WalkieTaskColors.yellow, spacing: 0.5),),
        TextSpan(text: sms,style: WalkieTaskStyles().stylePrimary(size: alto * 0.018, color: WalkieTaskColors.white, spacing: 0.5)),
      ]),
    ),
  );
  Widget titleText = Container(
    child: Text(title,style: WalkieTaskStyles().stylePrimary(size: alto * 0.02, color: WalkieTaskColors.white, spacing: 0.5, fontWeight: FontWeight.bold),),
  );
  flushBarNotification(
      context: context,
      avatar: imageAvatar,
      titleText: titleText,
      messageText: messageText,
      onTap: (flushbar) {}
  );
}