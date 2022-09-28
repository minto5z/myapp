import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:myapp/src/data/config.dart';
import 'package:myapp/src/models/setting.dart';
import 'package:myapp/src/pages/HomeScreen.dart';
import 'package:provider/provider.dart';

import '../helpers/HexColor.dart';
import '../helpers/SharedPref.dart';
import '../models/settings.dart';
import '../repository/settings_service.dart';
import '../services/theme_manager.dart';

class SplashScreen extends StatefulWidget {
  final Uint8List bytesImgSplashBase64;
  final Uint8List byteslogoSplashBase64;

  const SplashScreen(
      {super.key,
      required this.bytesImgSplashBase64,
      required this.byteslogoSplashBase64});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();
  String url = "";
  bool applicationProblem = false;

  _SplashScreen();

  @override
  void initState() {
    super.initState();
    Timer.run(() {
      initSetting();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initSetting() async {
    try {
      // var themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
      // themeProvider
      //     .setFont(Setting.getValue(_settings.setting!, "google_font"));

      _mockCheckForSession().then((status) {
        var future =
            Future.delayed(const Duration(milliseconds: 150), _navigateToHome);
      });
    } on Exception catch (exception) {
      setState(() {
        applicationProblem = true;
      });
    } catch (Excepetion) {
      setState(() {
        applicationProblem = true;
      });
    }
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    return true;
  }

  Future<String?> networkImageToBase64(String imageUrl) async {
    Response response = await get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  Future<void> _navigateToHome() async {
    url = await sharedPref.read("api_base_url");
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(url)));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color firstColor =
        HexColor('${GlobalConfiguration().getValue('firstColor')}');

    Color secondColor =
        HexColor('${GlobalConfiguration().getValue('secondColor')}');
    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                  0,
                  1
                ],
                    colors: [
                  firstColor,
                  secondColor,
                ])),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: Image.memory(
                widget.bytesImgSplashBase64,
                fit: BoxFit.cover,
                height: height,
                width: width,
                alignment: Alignment.center,
              )),
          Align(
            alignment: Alignment.center,
            child: Image.memory(widget.byteslogoSplashBase64,
                height: 150, width: 150),
          ),
          Align(alignment: Alignment.center, child: Config.logo),
          (applicationProblem == true)
              ? Positioned(
                  bottom: 160,
                  right: 0,
                  left: 0,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: const [
                          Text(
                            "System down for maintenance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                          Text(
                            "We're sorry, our system is not avaible",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                        ],
                      )))
              : Container()
        ],
      ),
    );
  }
}
