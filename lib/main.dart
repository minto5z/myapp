import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:myapp/src/enum/connectivity_status.dart';
import 'package:myapp/src/helpers/ConnectivityService.dart';
import 'package:myapp/src/pages/SplashScreen.dart';
import 'package:provider/provider.dart';

import 'src/services/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(debug: true);

  await GlobalConfiguration().loadFromAsset("configuration");

  // Uint8List? imgSplashBase64;
  // Uint8List? logoSplashBase64;

  // To turn off landscape mode
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  // imgSplashBase64 =
  //     await networkImageToBase64(GlobalConfiguration().getValue('img_splash_url'));
  //
  // logoSplashBase64 =
  //     await networkImageToBase64(GlobalConfiguration().getValue('logo_splash_url'));

  runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(), child: const MyApp()));
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
  const MyApp({Key? key}) : super(key: key);

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
    return const SplashScreen();
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
