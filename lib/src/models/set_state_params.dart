import 'tunnel.dart';

class SetStateParams {
  final bool state;
  final Tunnel tunnel;

  SetStateParams({
    required this.state,
    required this.tunnel,
  });

  Map<String, dynamic> toJson() => {
        'state': state,
        'tunnel': tunnel.toJson(),
      };
}
