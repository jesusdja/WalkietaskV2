import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:walkietaskv2/utils/Colores.dart';
import 'package:walkietaskv2/utils/WidgetsUtils.dart';
import 'package:open_file/open_file.dart';

Future downloadFile({
  @required String url,
  @required String idMyUser,
  @required BuildContext contextHome
}) async {
    try{
      String _localPath = (await _findLocalPath(contextHome)) + Platform.pathSeparator + 'Download';
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }

      String fileName = url.split('/').last;
      String fileDownload = '$_localPath/$fileName';
      bool exist = File(fileDownload).existsSync();
      if (exist) {
        OpenFile.open(fileDownload);
      }else{
        await FlutterDownloader.enqueue(
            url: url,
            headers: {"auth": "test_for_sql_encoding"},
            savedDir: _localPath,
            showNotification: true,
            openFileFromNotification: true);
        showAlert('Se inicio la descarga del archivo.', WalkieTaskColors.color_89BD7D);
      }
    }catch(e){
      print(e.toString());
    }
}

Future<String> _findLocalPath(BuildContext context) async {
  final directory = Theme.of(context).platform == TargetPlatform.android
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return directory.path;
}

// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:ext_storage/ext_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:walkietaskv2/utils/Colores.dart';
// import 'package:walkietaskv2/utils/Globales.dart';
// import 'package:walkietaskv2/utils/WidgetsUtils.dart';
//
// void downloadFile({@required String url, @required String idMyUser }) async{
//   try{
//
//     String path = await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOWNLOADS);
//
//     String fileName = url.replaceAll('%', '/');
//     fileName = fileName.split('/').last;
//     int pos = fileName.indexOf('U$idMyUser');
//     fileName = fileName.substring(pos + 3, fileName.length);
//
//     String fullPath = "$path/$fileName";
//
//     //get pdf from link
//     var dio = Dio();
//     Response response = await dio.get(
//       url,
//       onReceiveProgress: showDownloadProgress,
//       options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: false,
//           validateStatus: (status) {
//             return status < 500;
//           }),
//     );
//     //write in download folder
//     File file = File(fullPath);
//     var raf = file.openSync(mode: FileMode.write);
//     raf.writeFromSync(response.data);
//     await raf.close();
//
//   }catch(e){
//     print(e.toString());
//     bool conect = await checkConectivity();
//     if(!conect){
//       showAlert('Problemas con la conexión a internet.',WalkieTaskColors.color_DD7777);
//     }
//   }
// }
//
// void showDownloadProgress(received, total){
//   if(total != -1){
//     double tll = (received / total * 100);
//     print('${tll.toStringAsFixed(0)}%');
//   }
// }