import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:walkietaskv2/models/Policy.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

const _accessKeyId = 'AKIA3RY5LSSB2KEJP3HX';
const _secretKeyId = 'PsvOg4GzJOOoSf0VMxbZa/gN+RmFPUYkhzOBdIlz';
const _region = 'us-east-2';
const _s3Endpoint ='https://walkietask-bucket.s3-us-east-2.amazonaws.com';

String nameUser = 'walkietask-bucket';

Future<Map<String,String>> subirAudio(String ruta) async{

  Map<String,String> mapRes = new Map<String,String>();
  mapRes['subir'] = 'false';
  String idMyUser = await SharedPrefe().getValue('unityIdMyUser');
  DateTime f = DateTime.now();
  String nombreSubido = '${f.day}${f.month}${f.year}${f.hour}${f.minute}${f.second}U$idMyUser';

  try {

    final file = File(ruta);
    final stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    final length = await file.length();

    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile('file', stream, length,filename: path.basename(file.path));

    final policy = Policy.fromS3PresignedPost('audios/$nombreSubido.mp4',nameUser, _accessKeyId, 15, length,region: _region);
    final key = SigV4.calculateSigningKey(_secretKeyId, policy.datetime, _region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    final res = await req.send();
    print('${res.headers['location']}');

    mapRes['subir'] = 'true';
    mapRes['location'] = '${res.headers['location']}';

  } catch (e) {
    mapRes['subir'] = 'false';
    mapRes['error'] = e.toString();
    print(e.toString());
  }
  return mapRes;
}

Future<Map<String,String>> subirArchivo(String ruta) async{

  Map<String,String> mapRes = new Map<String,String>();
  mapRes['subir'] = 'false';

  String idMyUser = await SharedPrefe().getValue('unityIdMyUser');
  DateTime f = DateTime.now();
  String nombre = ruta.split('/').last;
  String nombreSubido = '${f.day}${f.month}${f.year}${f.hour}${f.minute}${f.second}U$idMyUser$nombre';

  try {
    final file = File(ruta);
    final stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
    final length = await file.length();

    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest("POST", uri);
    final multipartFile = http.MultipartFile('file', stream, length,filename: path.basename(file.path));

    final policy = Policy.fromS3PresignedPost('attached/$nombreSubido',nameUser, _accessKeyId, 15, length,region: _region);
    final key = SigV4.calculateSigningKey(_secretKeyId, policy.datetime, _region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());

    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    final res = await req.send();

    print('${res.headers['location']}');
    mapRes['subir'] = 'true';
    mapRes['location'] = '${res.headers['location']}';

  } catch (e) {
    print(e.toString());
  }
  return mapRes;
}