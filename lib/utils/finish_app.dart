import 'package:walkietaskv2/services/Conexionhttp.dart';
import 'package:walkietaskv2/services/Sqlite/ConexionSqlite.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

Future<void> finishApp() async{
  try{

    try{
      await conexionHttp().httpUpdateTokenFirebase('');
    }catch(e){
      print('ERROR AL OBTENER USUARIO EN TOKEN');
    }

    await SharedPrefe().deleteValue('unityInit');
    await SharedPrefe().deleteValue('unityIdMyUser');
    await SharedPrefe().deleteValue('unityLogin');
    await SharedPrefe().deleteValue('unityTokenExp');
    await SharedPrefe().deleteValue('unityToken');
    await SharedPrefe().deleteValue('unityEmail');
    await SharedPrefe().deleteValue('walkietaskFilterDate2');
    await SharedPrefe().deleteValue('walkietaskFilterDate');
    await SharedPrefe().deleteValue('walkietaskIdNoti');
    await SharedPrefe().deleteValue('idSoundWalkie');
    await SharedPrefe().deleteValue('WalListDocument');
    await SharedPrefe().deleteValue('notiListChat');
    await SharedPrefe().deleteValue('notiSend');
    await SharedPrefe().deleteValue('notiContacts');
    await SharedPrefe().deleteValue('notiRecived');
    await SharedPrefe().deleteValue('notiContacts_received');
    await SharedPrefe().deleteValue('notiListTask');
    await SharedPrefe().deleteValue('notiNewInvitation');
    await SharedPrefe().deleteValue('first');
    await SharedPrefe().deleteValue('openTask');
    await SharedPrefe().deleteValue('popValueTask');
    await SharedPrefe().deleteValue('listOrderRecived');
    await SharedPrefe().deleteValue('listOrderSend');
    await SharedPrefe().deleteValue('listOrderRecivedDate');
    await SharedPrefe().deleteValue('listOrderSendDate');
    await SharedPrefe().deleteValue('WalkiephotoUser');
    await SharedPrefe().deleteValue('WalListUpdateAvatar');
    await SharedPrefe().deleteValue('posPersonal');
    await SharedPrefe().deleteValue('WalListPhotosProjects');

    await DatabaseProvider.db.deleteDatabaseInstance();

    print('TODO LIMPIO');
  }catch(e){
    print(e.toString());
  }
}