import 'package:flutter/services.dart';

class service_messaging {
  static const platform = const MethodChannel('com.taosif7.linkring/methodChannel');
  static service_messaging _service_instance;

  service_messaging._() {}

  static service_messaging get instance => _service_instance ??= service_messaging._();

  Future<String> getPushToken() async {
    String token;
    try {
      final String result = await platform.invokeMethod('getPushToken');
      token = result;
    } on PlatformException catch (e) {
      print("Some error occurred: " + e.message);
    }
    return token;
  }
}
