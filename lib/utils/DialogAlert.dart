import 'package:flutter/material.dart';

Future<bool> alert(BuildContext context) async{
  bool res = await showDialog(
      context: context,
      builder: ( context ) {
        return AlertDialog(
          title: Text(''),
          content: Text('¿Esta seguro que desea cerrar sesión?',textAlign: TextAlign.center,),
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
