# wireguard_vpn

A Flutter plugin that enables the activation and deactivation of VPN connections using [WireGuard](https://www.wireguard.com/).

## Setup
- Modify the file /android/app/build.gradle and set the minSdkVersion to 21:
``` gradle
android {                    
   defaultConfig {
      minSdkVersion 21
  }                                
}
```
- To run the application in release mode, you must add a file named ```proguard-rules.pro``` with the following content to the ```./android/app/``` directory:
```
-keep class app.wachu.wireguard_vpn.** {*;}
-keep class com.beust.klaxon.** {*;}
```
- Another option is to add the following to the ```./android/app/build.gradle``` file under the ```buildtypes release```:
```
shrinkResources false
minifyEnabled false
```
### I'd like to thank the user [ByteSizedMarius](https://github.com/ByteSizedMarius) for their contribution regarding the execution in release mode of the package. Thank you.
## Usage

To use this plugin, you must first add it to your pubspec.yaml file:

``` yaml
dependencies:
  wireguard_vpn: ^0.0.2 
```

Then, import the package in your .dart file:
``` dart
import 'package:wireguard_vpn/wireguard_vpn.dart';
```

## Activate and Deactivate VPN

To activate or deactivate the VPN connection, use the changeStateParams method of the WireguardFlutterPlugin class. This method takes a SetStateParams object as a parameter, which includes information about the VPN tunnel.

``` dart
bool vpnActivate = false;
String initName = "MyWireguardVPN";
String initAddress = "192.168.1.1/24";
String initDnsServer = "8.8.8.8";
String initPort = "51820";
String initAllowedIp = "0.0.0.0/0";
String initEndpoint = "vpn.example.com:51820";
String initPublicKey = "PUBLIC_KEY";
String initPrivateKey = "PRIVATE_KEY";
String presharedKey = "PRESHARED_KEY";

final _wireguardFlutterPlugin = WireguardFlutterPlugin();

void _activateVpn(bool value) async {
  final results = await _wireguardFlutterPlugin.changeStateParams(SetStateParams(
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
  });
}
```

## Obtain connection statistics

To obtain statistics of the VPN connection, use the tunnelGetStats method of the WireguardFlutterPlugin class. This method takes the name of the VPN tunnel as a parameter.

``` dart
String initName = "MyWireguardVPN";

final _wireguardFlutterPlugin = WireguardFlutterPlugin();

void _obtainStats() {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final results = await _wireguardFlutterPlugin.tunnelGetStats(initName);
    setState(() {
      stats = results ?? Stats(totalDownload: 0, totalUpload: 0);
    });
  });
}
```
## Complete example

Here's an example of how to use this plugin to activate and deactivate the VPN connection and obtain connection statistics:

``` dart
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
```
For more information, you can check the [example tab](https://pub.dev/packages/wireguard_vpn/example) or the [GitHub repository](https://github.com/Wachu985/flutter_wireguard_vpn).

## Generate WireGuard VPN configurations
**To obtain WireGuard VPN configurations for testing, you can visit the [PotonVPN](https://account.protonvpn.com/login) website, register, and generate a configuration under the downloads section. You can also follow the guide on the official [WireGuard VPN](https://www.wireguard.com/) website.**

## Contributions

Contributions are welcome. If you find a bug or want to add a new feature, please open a new [issue](https://github.com/Wachu985/flutter_wireguard_vpn/issues) or send a [pull request](https://github.com/Wachu985/flutter_wireguard_vpn/pulls).

## License

This package is available under the terms of the [BSD 3-clause license](https://opensource.org/license/bsd-3-clause/). Please refer to the [LICENSE](https://pub.dev/packages/wireguard_vpn/license) file for more information.
