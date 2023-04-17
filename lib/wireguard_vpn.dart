import 'src/models/models.dart';
import 'wireguard_vpn_platform_interface.dart';

export 'src/models/models.dart';
export 'src/errors/exceptions.dart';

class WireguardVpn {
  //
  Future<bool?> changeStateParams(SetStateParams params) {
    return WireguardVpnPlatform.instance.changeStateParams(params);
  }

  //
  Future<String?> runningTunnelNames() {
    return WireguardVpnPlatform.instance.runningTunnelNames();
  }

  //
  Future<Stats?> tunnelGetStats(String name) {
    return WireguardVpnPlatform.instance.tunnelGetStats(name);
  }
}
