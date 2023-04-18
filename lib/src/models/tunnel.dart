class Tunnel {
  final String name;
  final String address;
  final String listenPort;
  final String dnsServer;
  final String privateKey;
  final String peerAllowedIp;
  final String peerPublicKey;
  final String peerEndpoint;
  final String peerPresharedKey;

  /// Constructor of the [Tunnel] class that receives the [name] of the tunnel,
  /// the [address] IP address of the local, [listenPort] listen port,
  /// [dnsServer] DNS servers, [privateKey] server private key,
  /// [peerAllowedIp] allowed IP addresses, [peerEndpoint] server IP address,
  /// [peerPresharedKey] server preshared key.
  Tunnel(
      {required this.name,
      required this.address,
      required this.listenPort,
      required this.dnsServer,
      required this.privateKey,
      required this.peerAllowedIp,
      required this.peerPublicKey,
      required this.peerEndpoint,
      required this.peerPresharedKey});

  /// Method [toJson] to convert the class to JSON.
  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'listenPort': listenPort,
        'dnsServer': dnsServer,
        'privateKey': privateKey,
        'peerAllowedIp': peerAllowedIp,
        'peerPublicKey': peerPublicKey,
        'peerEndpoint': peerEndpoint,
        'peerPresharedKey': peerPresharedKey
      };
}
