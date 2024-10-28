import 'package:flutter/services.dart';

class ScreenUtils {
  static const MethodChannel _channel =
      MethodChannel('com.yourapp.screen_utils');

  static Future<void> setFullScreen(bool enable) async {
    try {
      await _channel.invokeMethod('setFullScreen', {'enable': enable});
    } on PlatformException catch (e) {
      print('Error al establecer pantalla completa: ${e.message}');
    }
  }

  static Future<void> setOrientation(String orientation) async {
    try {
      await _channel
          .invokeListMethod('setOrientation', {'orientation': orientation});
    } on PlatformException catch (e) {
      print('Error al establecer orientación: ${e.message}');
    }
  }
}
