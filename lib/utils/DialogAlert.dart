import 'package:flutter/material.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/walkietask_style.dart';

Future<bool> alert(BuildContext context) async{
  Size size = MediaQuery.of(context).size;
  bool res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('¿Estás seguro que desea cerrar sesión?',textAlign: TextAlign.center,
            style: WalkieTaskStyles().stylePrimary(size: size.height * 0.025, color: WalkieTaskColors.color_969696,spacing: 0.5,fontWeight: FontWeight.bold),),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok',
              style: WalkieTaskStyles().stylePrimary(size: size.height * 0.02, color: WalkieTaskColors.primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            FlatButton(
              child: Text('Cancelar',
                style: WalkieTaskStyles().stylePrimary(size: size.height * 0.02, color: WalkieTaskColors.primary,fontWeight: FontWeight.bold),),
              onPressed: (){
                Navigator.of(context).pop(false);
                return false;
              },
            ),
          ],
        );
      }
  );
  return res;
}

Future<bool> alertDeleteElement(BuildContext context, String question) async{

  Size size = MediaQuery.of(context).size;

  bool res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text(question,
            textAlign: TextAlign.center,
            style: WalkieTaskStyles().stylePrimary(size: size.height * 0.025, color: WalkieTaskColors.color_969696,spacing: 0.5,fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok',
                style: WalkieTaskStyles().stylePrimary(size: size.height * 0.02, color: WalkieTaskColors.primary,fontWeight: FontWeight.bold),),
              onPressed: ()  {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            FlatButton(
              child: Text('Cancelar',
                style: WalkieTaskStyles().stylePrimary(size: size.height * 0.02, color: WalkieTaskColors.primary,fontWeight: FontWeight.bold),),
              onPressed: (){
                Navigator.of(context).pop(false);
                return false;
              },
            ),
          ],
        );
      }
  );
  return res;
}
