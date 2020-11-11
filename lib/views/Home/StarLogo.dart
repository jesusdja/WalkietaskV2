import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkietaskv2/services/auth.dart';

class StartLogo extends StatefulWidget {
  @override
  _StarLogoState createState() => _StarLogoState();
}

class _StarLogoState extends State<StartLogo> with SingleTickerProviderStateMixin{
  AuthService auth;
  Future<bool> exit() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthService>(context);

    return WillPopScope(
        child: FutureBuilder(
          future: auth.init(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot){

            Widget bdy = Container();
            switch(snapshot.connectionState){
              case ConnectionState.none:
                bdy =  Container(
                  child: Center(
                    child: Text('Error'),
                  ),
                );
                break;
              case ConnectionState.waiting:
                bdy =  Center(child: CircularProgressIndicator(),);
                break;
              case ConnectionState.active:
                bdy =  Center(child: CircularProgressIndicator(),);
                break;
              case ConnectionState.done:
                bdy =  Center(child: CircularProgressIndicator(),);
                break;
            }

            return Scaffold(
              body: bdy,
            );
          },
        ),
        onWillPop: exit
    );
  }
}