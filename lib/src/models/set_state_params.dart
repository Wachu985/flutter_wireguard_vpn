import 'tunnel.dart';

class SetStateParams {
  final bool state;
  final Tunnel tunnel;

  /// Constructor of the [SetStateParams] class that receives [state], a boolean that defines the
  /// value that the tunnel is going to receive, [tunnel], an object of the [Tunnel] class that is the
  /// tunnel to be modified.
  SetStateParams({
    required this.state,
    required this.tunnel,
  });

  /// Method [toJson] to convert the class to JSON.
  Map<String, dynamic> toJson() => {
        'state': state,
        'tunnel': tunnel.toJson(),
      };
}
