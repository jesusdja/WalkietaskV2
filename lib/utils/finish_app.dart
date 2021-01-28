import 'package:walkietaskv2/services/ActualizacionDatos.dart';
import 'package:walkietaskv2/utils/shared_preferences.dart';

Future<void> finishApp() async{
  try{
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

    await UpdateData().resetDB();
    print('TODO LIMPIO');
  }catch(e){
    print(e.toString());
  }
}