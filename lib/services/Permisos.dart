import 'package:permission_handler/permission_handler.dart';

Future<bool> PermisoSonido() async {

  bool result = false;
  PermissionHandler _permissionHandler = PermissionHandler();

  final status = await _permissionHandler.checkPermissionStatus(PermissionGroup.microphone);
  if(status == PermissionStatus.granted){
    result = true;
  }else{
    final resultP = await _permissionHandler.requestPermissions([PermissionGroup.microphone]);
    if(resultP.containsKey(PermissionGroup.microphone)){
      if(resultP[PermissionGroup.microphone] == PermissionStatus.granted){
        result = true;
      }else{
        final res = await _permissionHandler.openAppSettings();
        if(res){
          PermisoSonido();
        }
      }
    }
  }

  return result;
}
Future<bool> PermisoPhotos() async {

  bool result = false;
  PermissionHandler _permissionHandler = PermissionHandler();

  final status = await _permissionHandler.checkPermissionStatus(PermissionGroup.photos);
  if(status == PermissionStatus.granted){
    result = true;
  }else{
    final resultP = await _permissionHandler.requestPermissions([PermissionGroup.photos]);
    if(resultP.containsKey(PermissionGroup.photos)){
      if(resultP[PermissionGroup.photos] == PermissionStatus.granted){
        result = true;
      }else{
        final res = await _permissionHandler.openAppSettings();
        if(res){
          PermisoSonido();
        }
      }
    }
  }

  return result;
}
Future<bool> PermisoStore() async {

  bool result = false;
  PermissionHandler _permissionHandler = PermissionHandler();

  final status = await _permissionHandler.checkPermissionStatus(PermissionGroup.storage);
  if(status == PermissionStatus.granted){
    result = true;
  }else{
    final resultP = await _permissionHandler.requestPermissions([PermissionGroup.storage]);
    if(resultP.containsKey(PermissionGroup.storage)){
      if(resultP[PermissionGroup.storage] == PermissionStatus.granted){
        result = true;
      }else{
        final res = await _permissionHandler.openAppSettings();
        if(res){
          PermisoSonido();
        }
      }
    }
  }

  return result;
}