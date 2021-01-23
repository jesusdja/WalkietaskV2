import 'package:shared_preferences/shared_preferences.dart';
import 'package:walkietaskv2/services/ActualizacionDatos.dart';

Future<void> finishApp() async{
  try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('unityToken');
    await prefs.remove('unityTokenExp');
    await prefs.remove('unityLogin');
    await prefs.remove('unityIdMyUser');
    await prefs.remove('WalListDocument');
    await prefs.remove('unityEmail');
    await prefs.remove('walkietaskIdNoti');
    await prefs.remove('walkietaskFilterDate');
    await prefs.remove('walkietaskFilterDate2');
    await prefs.remove('notiRecived');
    await prefs.remove('notiSend');
    await prefs.remove('notiContacts');
    await prefs.remove('notiContacts_received');
    await prefs.remove('notiListTask');
    await prefs.remove('notiListChat');

    await UpdateData().resetDB();
    print('TODO LIMPIO');
  }catch(e){
    print(e.toString());
  }
}