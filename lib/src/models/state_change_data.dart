class StateChangeData {
  final String tunnelName;
  final bool tunnelState;

  StateChangeData({
    required this.tunnelName,
    required this.tunnelState,
  });

  Map<String, dynamic> toJson() => {
        'tunnelName': tunnelName,
        'tunnel': tunnelState,
      };

  factory StateChangeData.fromJson(Map<String, dynamic> json) {
    return StateChangeData(
      tunnelName: json['tunnelName'] as String,
      tunnelState: (json['tunnelState'] as bool?) ?? false,
    );
  }
}
