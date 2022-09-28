import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../enum/connectivity_status.dart';
import '../helpers/HexColor.dart';
import '../pages/OfflineScreen.dart';
import '../position/PositionOptions.dart';
import '../position/PositionResponse.dart';
import '../services/theme_manager.dart';
import 'Loader.dart';
import 'WebViewElement.dart';

//import 'package:location/location.dart' hide LocationAccuracy;
//import 'package:store_redirect/store_redirect.dart';

class WebViewElementState extends State<WebViewElement>
    with AutomaticKeepAliveClientMixin<WebViewElement>, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  //final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  bool isLoading = true;
  String url = "";
  late PullToRefreshController pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          allowFileAccess: true,
          allowContentAccess: true),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  //List<StreamSubscription<Position>> webViewGPSPositionStreams = [];

  bool isWasConnectionLoss = false;
  bool _permissionReady = false;
  bool mIsPermissionGrant = false;
  bool mIsLocationPermissionGrant = false;

  late var _localPath;
  final ReceivePort _port = ReceivePort();

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = {
    Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    // webViewGPSPositionStreams.forEach(
    //     (StreamSubscription<Position> _flutterGeolocationStream) =>
    //         _flutterGeolocationStream.cancel());
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  Future<bool> checkPermission() async {
    print("check permission");
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          mIsPermissionGrant = true;
          setState(() {});
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  bool contains(List<String> list, String item) {
    for (String i in list) {
      if (item.contains(i)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);

    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    if (connectionStatus == ConnectivityStatus.Offline) {
      return const OfflineScreen();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(children: [
          Expanded(
              child: InAppWebView(
                  initialUrlRequest:
                      URLRequest(url: Uri.parse(widget.initialUrl!)),
                  gestureRecognizers: _gSet,
                  initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        supportZoom: false,
                        useShouldOverrideUrlLoading: true,
                        useOnDownloadStart: true,
                        mediaPlaybackRequiresUserGesture: false,
                        // userAgent: Platform.isAndroid
                        //     ? widget.userAgent!.valueAndroid!
                        //     : widget.userAgent!.valueIOS!
                      ),
                      android: AndroidInAppWebViewOptions(
                        allowFileAccess: true,
                        allowContentAccess: true,
                        useHybridComposition: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      )),
                  pullToRefreshController: widget.pullRefresh == "true"
                      ? pullToRefreshController
                      : null,
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      isLoading = true;
                    });
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController.endRefreshing();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _geolocationAlertFix();
                    });

                    // webViewController!.injectCSSCode(source: widget.customCss!);
                    // webViewController!
                    //     .evaluateJavascript(source: widget.customJavascript!);

                    setState(() {
                      this.url = url.toString();
                      isLoading = false;
                    });
                    if (widget.onLoadEnd != null) {
                      widget.onLoadEnd!();
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url;
                    var url = navigationAction.request.url.toString();
                    //log("URL" + url.toString());

                    if (Platform.isAndroid && url.contains("intent")) {
                      if (url.contains("maps")) {
                        var mNewURL = url.replaceAll("intent://", "https://");
                        if (await canLaunch(mNewURL)) {
                          await launch(mNewURL);
                          return NavigationActionPolicy.CANCEL;
                        }
                      } else {
                        String id = url.substring(
                            url.indexOf('id%3D') + 5, url.indexOf('#Intent'));
                        print(id);
                        //await StoreRedirect.redirect(androidAppId: id);
                        return NavigationActionPolicy.CANCEL;
                      }
                    } else if (![
                      "http",
                      "https",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri!.scheme)) {
                      if (await canLaunch(url)) {
                        await launch(
                          url,
                        );
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onDownloadStart: (controller, url) async {
                    print("onDownloadStart");
                    checkPermission().then((hasGranted) async {
                      try {
                        _permissionReady = hasGranted;
                        if (_permissionReady == true) {
                          if (Platform.isIOS) {
                            _localPath =
                                await getApplicationDocumentsDirectory();
                          } else {
                            _localPath = "/storage/emulated/0/Download/";
                          }
                          //String localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

                          final savedDir = Directory(_localPath);
                          bool hasExisted = await savedDir.exists();
                          if (!hasExisted) {
                            savedDir.create();
                          }
                          print("local Path" + _localPath);

                          print("url.scheme------");
                          print(url.toString());
                          final taskId = await FlutterDownloader.enqueue(
                              url: url.toString(),
                              savedDir: _localPath,
                              showNotification: true,
                              // show download progress in status bar (for Android)
                              openFileFromNotification: true,
                              // click on notification to open downloaded file (for Android)
                              requiresStorageNotLow: false);
                          final tasks = await FlutterDownloader.loadTasks();
                          print('tasks: $tasks');
                        }
                      } catch (error) {
                        print("error------");
                        print(error);
                      }
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController.endRefreshing();
                    }
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                  /*androidOnGeolocationPermissionsShowPrompt:
            (InAppWebViewController controller, String origin) async {
          print("androidOnGeolocationPermissionsShowPrompt");
          await Permission.location.request();
          return Future.value(GeolocationPermissionShowPromptResponse(
              origin: origin, allow: true, retain: true));
        },*/
                  androidOnPermissionRequest:
                      (InAppWebViewController controller, String origin,
                          List<String> resources) async {
                    print("androidOnPermissionRequest");
                    if (resources.length >= 1) {
                    } else {
                      resources.forEach((element) async {
                        if (element.contains("AUDIO_CAPTURE")) {
                          await Permission.microphone.request();
                        }
                        if (element.contains("VIDEO_CAPTURE")) {
                          await Permission.camera.request();
                        }
                      });
                    }
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  onWebViewCreated: (InAppWebViewController controller) {
                    controller.addJavaScriptHandler(
                        handlerName: '_flutterGeolocation',
                        callback: (args) {
                          dynamic geolocationData;
                          // try to decode json
                          try {
                            geolocationData = json.decode(args[0]);
                            //geolocationData = json.decode(args[0].message);
                          } catch (e) {
                            // empty or what ever
                            return;
                          }
                          // Get action from JSON
                          final String action = geolocationData['action'] ?? "";

                          switch (action) {
                            case "clearWatch":
                              break;

                            case "getCurrentPosition":
                              break;

                            case "watchPosition":
                              break;
                            default:
                          }
                        });
                    webViewController = controller;
                  })),
        ]),
        (isLoading && widget.loader != "empty")
            ? Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Loader(
                    type: widget.loader!,
                    color: themeProvider.isLightTheme
                        ? HexColor(widget.loaderColor!)
                        : themeProvider.darkTheme.primaryColor))
            : Container()
      ],
    );
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value);
  }

  Future<PositionResponse> getCurrentPosition(
      PositionOptions positionOptions) async {

    bool _serviceEnabled;

    PositionResponse positionResponse = PositionResponse();

    int timeout = 30000;
    if (positionOptions.timeout > 0) timeout = positionOptions.timeout;

    try {
      bool serviceEnabled;

      // Test if location services are enabled.
    } catch (e) {
      bool _serviceEnabled;
    }

    return positionResponse;
  }

  void _geolocationAlertFix() {
    String javascript = '''
      var _flutterGeolocationIndex = 0;
      var _flutterGeolocationSuccess = [];
      var _flutterGeolocationError = [];
      function _flutterGeolocationAlertFix() {
        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}}));
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
        };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
          return _flutterGeolocationIndex;
        };
        return true;
      };
      setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
    ''';

    webViewController!.evaluateJavascript(source: javascript);

    webViewController!.evaluateJavascript(source: """
      function _flutterGeolocationAlertFix() {
        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
  
  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}})      ).then(function(result) {
      //alert(result);
    }); 
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
  
     _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
       
  window.flutter_inappwebview.callHandler('_flutterGeolocation',       JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });       
    
     };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
        
         _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          
  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });    
          return _flutterGeolocationIndex;
        };
        return true;
    }
          setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
  """);
  }

  Future<bool?> goBack() async {
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      } else {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('closeApp'),
            content: const Text('sureCloseApp'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('cancel'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('ok'),
              ),
            ],
          ),
        );
      }
    }
    return false;
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }
}
