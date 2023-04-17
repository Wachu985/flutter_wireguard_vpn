import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/models/models.dart';
import 'wireguard_vpn_method_channel.dart';

abstract class WireguardVpnPlatform extends PlatformInterface {
  /// Constructs a WireguardVpnPlatform.
  WireguardVpnPlatform() : super(token: _token);

  static final Object _token = Object();

  static WireguardVpnPlatform _instance = MethodChannelWireguardVpn();

  /// The default instance of [WireguardVpnPlatform] to use.
  ///
  /// Defaults to [MethodChannelWireguardVpn].
  static WireguardVpnPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WireguardVpnPlatform] when
  /// they register themselves.
  static set instance(WireguardVpnPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> changeStateParams(SetStateParams params) {
    throw UnimplementedError('changeStateParams() has not been implemented.');
  }

  //
  Future<String?> runningTunnelNames() {
    throw UnimplementedError('runningTunnelNames() has not been implemented.');
  }

  //
  Future<Stats?> tunnelGetStats(String name) {
    throw UnimplementedError('runningTunnelNames() has not been implemented.');
  }
}
