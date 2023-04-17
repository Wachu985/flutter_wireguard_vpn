import 'dart:convert';

// import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/errors/exceptions.dart';
import 'src/models/models.dart';
import 'wireguard_vpn_platform_interface.dart';

/// An implementation of [WireguardVpnPlatform] that uses method channels.
class MethodChannelWireguardVpn extends WireguardVpnPlatform {
  /// The method channel used to interact with the native platform.
  final methodChannel = const MethodChannel('wachu985/wireguard-flutter');

  @override
  Future<bool?> changeStateParams(SetStateParams params) async {
    try {
      final state = await methodChannel.invokeMethod<bool>(
          'setState', jsonEncode(params.toJson()));

      return state;
    } on Exception catch (e) {
      throw ConnectionException(message: e.toString());
    }
  }

  @override
  Future<String?> runningTunnelNames() async {
    try {
      final result = await methodChannel.invokeMethod('getTunnelNames');
      return result;
    } on PlatformException catch (e) {
      throw ConnectionException(message: e.message ?? '');
    }
  }

  @override
  Future<Stats?> tunnelGetStats(String name) async {
    try {
      final result = await methodChannel.invokeMethod('getStats', name);
      final stats = Stats.fromJson(jsonDecode(result));
      return stats;
    } on Exception catch (e) {
      throw ConnectionException(message: e.toString());
    }
  }
}
