import 'src/models/models.dart';
import 'wireguard_vpn_platform_interface.dart';

export 'src/models/models.dart';
export 'src/errors/exceptions.dart';

/// Main Class
class WireguardVpn {
  /// Method [changeStateParams] that receives [params] of the [SetStateParams] class and returns true or false
  /// when activating or deactivating the tunnel state.
  Future<bool?> changeStateParams(SetStateParams params) {
    return WireguardVpnPlatform.instance.changeStateParams(params);
  }

  /// Method [runningTunnelNames] returns the name of the running tunnel.
  Future<String?> runningTunnelNames() {
    return WireguardVpnPlatform.instance.runningTunnelNames();
  }

  /// Method [tunnelGetStats] receives the [name] of the tunnel that will take the Stats
  /// and returns an object of the [Stats] class with the values of the tunnel.
  Future<Stats?> tunnelGetStats(String name) {
    return WireguardVpnPlatform.instance.tunnelGetStats(name);
  }
}
