import 'dart:async';

import 'package:flutter/material.dart';

import 'package:wireguard_vpn/wireguard_vpn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _wireguardFlutterPlugin = WireguardVpn();
  bool vpnActivate = false;
  Stats stats = Stats(totalDownload: 0, totalUpload: 0);
  final String initName = 'MyWireguardVPN';
  final String initAddress = "10.7.0.2/24";
  final String initPort = "51820";
  final String initDnsServer = "8.8.8.8, 8.8.4.4";
  final String initPrivateKey = "PRIVATE_KEY";
  final String initAllowedIp = "0.0.0.0/0, ::/0";
  final String initPublicKey = "PUBLIC_KEY";
  final String initEndpoint = "vpn.example.com:51820";
  final String presharedKey = 'PRESHARED_KEY';

  @override
  void initState() {
    super.initState();
    vpnActivate ? _obtainStats() : null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Wireguard-VPN Example'),
          ),
          body: Column(
            children: [
              Text(
                  'Active VPN: ${stats.totalDownload} D -- ${stats.totalUpload} U'),
              SwitchListTile(
                value: vpnActivate,
                onChanged: _activateVpn,
                title: Text(initName),
                subtitle: Text(initEndpoint),
              ),
            ],
          )),
    );
  }

  void _obtainStats() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      final results = await _wireguardFlutterPlugin.tunnelGetStats(initName);
      setState(() {
        stats = results ?? Stats(totalDownload: 0, totalUpload: 0);
      });
    });
  }

  void _activateVpn(bool value) async {
    final results =
        await _wireguardFlutterPlugin.changeStateParams(SetStateParams(
      state: !vpnActivate,
      tunnel: Tunnel(
          name: initName,
          address: initAddress,
          dnsServer: initDnsServer,
          listenPort: initPort,
          peerAllowedIp: initAllowedIp,
          peerEndpoint: initEndpoint,
          peerPublicKey: initPublicKey,
          privateKey: initPrivateKey,
          peerPresharedKey: presharedKey),
    ));
    setState(() {
      vpnActivate = results ?? false;
      vpnActivate ? _obtainStats() : null;
    });
  }
}
