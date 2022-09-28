import 'package:myapp/src/models/setting.dart';
import 'package:myapp/src/models/splash.dart';

class Settings {
  List<dynamic>? setting = [];
  Splash? splash;
  Map<String, Map<String, String>> translation = {};

  Settings({
    this.setting,
    this.splash,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    if (json['settings'] != null) {
      setting = <Setting>[];
      json['settings'].forEach((v) {
        setting!.add(Setting.fromJson(v));
      });
    }

    if (json['splash'] != null) {
      splash = Splash.fromJson(json['splash']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (setting != null) {
      data['setting'] = setting!.map((v) => v.toJson()).toList();
    }

    if (splash != null) {
      data['splash'] = splash!.toJson();
    }
    return data;
  }
}
