import 'package:flutter/services.dart';

class AsrManager {
  static const MethodChannel _channel = const MethodChannel('asr_plugin');

  static Future<String> start({Map params}) async {
    return await _channel.invokeMethod('start', params ?? {});
  }

  static Future<String> stop({Map params}) async {
    return await _channel.invokeMethod('stop');
  }

  static Future<String> cancel({Map params}) async {
    return await _channel.invokeMethod('cancel');
  }
}