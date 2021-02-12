import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:walkietaskv2/services/auth.dart';
import 'package:walkietaskv2/views/Home/NavigatorBotton.dart';
import 'package:walkietaskv2/views/Login/LoginHome.dart';
import 'package:walkietaskv2/views/Home/StarLogo.dart';
import 'package:walkietaskv2/views/Register/widgets/register_code.dart';
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => AuthService.instance(),
      child: provider.Consumer(
        // ignore: missing_return
        builder: (context, AuthService auth, _){
          switch (auth.status) {
            case Status.Logo:
              return StartLogo();
            case Status.Login:
              return LoginHome();
            case Status.home:
              return NavigatorBottonPage();
            case Status.code:
              return RegisterCode(context);
          }
        },
      ),
    );
  }

}