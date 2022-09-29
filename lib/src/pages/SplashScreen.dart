import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:myapp/src/data/config.dart';
import 'package:myapp/src/pages/HomeScreen.dart';

import '../helpers/HexColor.dart';

class SplashScreen extends StatefulWidget {
  // final Uint8List bytesImgSplashBase64;
  // final Uint8List byteslogoSplashBase64;

  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
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
      _mockCheckForSession().then((status) {
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
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
              // child: Image.memory(
              //   widget.bytesImgSplashBase64,
              //   fit: BoxFit.cover,
              //   height: height,
              //   width: width,
              //   alignment: Alignment.center,
              // )
              child: Config.splash),
          // Align(
          //   alignment: Alignment.center,
          //   child: Image.memory(widget.byteslogoSplashBase64,
          //       height: 150, width: 150),
          // ),
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
