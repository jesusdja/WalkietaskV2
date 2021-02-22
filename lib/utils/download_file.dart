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