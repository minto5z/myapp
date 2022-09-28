import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:myapp/src/repository/settings_service.dart';

import '../elements/Loader.dart';
import '../helpers/HexColor.dart';
import '../helpers/SharedPref.dart';
import '../themes/UIImages.dart';
import 'SplashScreen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreen();
}

class _InitialScreen extends State<InitialScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();
  bool applicationProblem = false;

  Uint8List? bytesImgSplashBase64;

  Uint8List? byteslogoSplashBase64;

  @override
  void initState() {
    super.initState();
    Timer.run(() {
      getSetting();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getSetting() async {
    SharedPref sharedPref = SharedPref();
    var logoSplashUrl = GlobalConfiguration().getValue('logo_splash_url');
    var imgSplashUrl = GlobalConfiguration().getValue('img_splash_url');
    var apiBaseUrl = GlobalConfiguration().getValue('api_base_url');
    var loader = GlobalConfiguration().getValue('loader');
    var loaderColor = GlobalConfiguration().getValue('loaderColor');
    var pullRefresh = GlobalConfiguration().getValue('pull_refresh');

    sharedPref.save("logo_splash_url", logoSplashUrl);
    sharedPref.save("img_splash_url", imgSplashUrl);
    sharedPref.save("api_base_url", apiBaseUrl);
    sharedPref.save("loader", loader);
    sharedPref.save("loaderColor", loaderColor);
    sharedPref.save("pull_refresh", pullRefresh);
    Uint8List imgSplashBase64 = await networkImageToBase64(imgSplashUrl!);

    Uint8List logoSplashBase64 = await networkImageToBase64(logoSplashUrl!);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => SplashScreen(
            bytesImgSplashBase64: imgSplashBase64,
            byteslogoSplashBase64: logoSplashBase64)));
    if (sharedPref == null) {
      applicationProblem = true;
    }
  }

  Future<Uint8List> networkImageToBase64(String imageUrl) async {
    Response response = await get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color firstColor = HexColor(
        true ? "#FFFFFF" : '${GlobalConfiguration().getValue('firstColor')}');

    Color secondColor = HexColor(
        true ? "#FFFFFF" : '${GlobalConfiguration().getValue('secondColor')}');

    return Scaffold(
      backgroundColor: HexColor("#FFFFFF"),
      body: Column(children: [
        if (applicationProblem == true)
          Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Column(
                    children: [
                      SizedBox(
                          width: 110.0,
                          height: 110.0,
                          child: Image.asset(
                            "${UIImages.imageDir}/maintenance.png",
                            color: Colors.black,
                            fit: BoxFit.contain,
                          )),
                      const SizedBox(height: 70),
                      const Text(
                        "System down for maintenance",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      const Text(
                        "We're sorry, our system is not avaible",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      )
                    ],
                  ))),
        if (applicationProblem == false)
          Container(
            width: width,
            height: height,
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
            child: Loader(
              type: "Circle",
              color: HexColor("#000000"),
            ),
          )
      ]),
    );
  }
}
