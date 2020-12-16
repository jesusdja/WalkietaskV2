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
          content: Text('¿Esta seguro que desea cerrar sesión?',textAlign: TextAlign.center,
            style: WalkieTaskStyles().stylePrimary(size: size.height * 0.03, color: WalkieTaskColors.color_969696,spacing: 0.5,fontWeight: FontWeight.bold),),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: ()  {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            FlatButton(
              child: Text('Cancelar'),
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

Future<bool> alertDeleteProject(BuildContext context, String name) async{

  Size size = MediaQuery.of(context).size;

  bool res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('¿Esta seguro que desea Eliminar el proyecto "$name"?',
            textAlign: TextAlign.center,
            style: WalkieTaskStyles().stylePrimary(size: size.height * 0.03, color: WalkieTaskColors.color_969696,spacing: 0.5,fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: ()  {
                Navigator.of(context).pop(true);
                return true;
              },
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02,),
            FlatButton(
              child: Text('Cancelar'),
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
