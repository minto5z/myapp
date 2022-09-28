import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:myapp/src/enum/connectivity_status.dart';
import 'package:myapp/src/helpers/ConnectivityService.dart';
import 'package:myapp/src/helpers/SharedPref.dart';
import 'package:myapp/src/models/settings.dart';
import 'package:myapp/src/pages/InitialScreen.dart';
import 'package:myapp/src/pages/SplashScreen.dart';
import 'package:provider/provider.dart';

import 'src/services/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(debug: true);

  await GlobalConfiguration().loadFromAsset("configuration");

  SharedPref sharedPref = SharedPref();
  Settings? settings;
  Uint8List? imgSplashBase64;
  Uint8List? logoSplashBase64;

  // To turn off landscape mode
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  try {
    var set = await sharedPref.read("settings");
    if (set != null) {
      settings = Settings.fromJson(set);

      imgSplashBase64 =
          await networkImageToBase64(settings.splash!.img_splash_url!);

      logoSplashBase64 =
          await networkImageToBase64(settings.splash!.logo_splash_url!);

      if (imgSplashBase64 == null || logoSplashBase64 == null) {
        settings = null;
      }
    }
  } catch (exception) {
    print(exception);
  }

  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: MyApp(
          settings: settings,
          imgSplashBase64: imgSplashBase64,
          logoSplashBase64: logoSplashBase64)));
}

Future<Uint8List?> networkImageToBase64(String imageUrl) async {
  try {
    Response response = await get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return bytes;
    } else {
      return null;
    }
  } catch (err) {
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp(
      {Key? key,
      required this.settings,
      required this.imgSplashBase64,
      required this.logoSplashBase64})
      : super(key: key);
  final Settings? settings;
  final Uint8List? imgSplashBase64;
  final Uint8List? logoSplashBase64;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<ConnectivityStatus>(
        initialData: ConnectivityStatus.Wifi,
        create: (context) =>
            ConnectivityService().connectionStatusController.stream,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: renderHome(),
        ));
  }

  Widget renderHome() {
    if (settings == null) {
      return const InitialScreen();
    } else {
      return SplashScreen(
          bytesImgSplashBase64: imgSplashBase64!,
          byteslogoSplashBase64: logoSplashBase64!);
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(),
      ),
    );
  }
}
