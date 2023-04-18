class StateChangeData {
  final String tunnelName;
  final bool tunnelState;

  /// Constructor of the [StateChangeData] class that receives [tunnelName] which is the name
  /// of the tunnel, and [tunnelState] which is a boolean that can be true or false.
  StateChangeData({
    required this.tunnelName,
    required this.tunnelState,
  });

  /// Method [toJson] to convert the class to JSON.
  Map<String, dynamic> toJson() => {
        'tunnelName': tunnelName,
        'tunnel': tunnelState,
      };

  /// Method [StateChangeData.fromJson] to convert the JSON to class.
  factory StateChangeData.fromJson(Map<String, dynamic> json) {
    return StateChangeData(
      tunnelName: json['tunnelName'] as String,
      tunnelState: (json['tunnelState'] as bool?) ?? false,
    );
  }
}
