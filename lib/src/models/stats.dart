class Stats {
  final num totalDownload;
  final num totalUpload;

  /// Constructor of the [Stats] class that receives [totalDownload] where total downloaded data is stored,
  /// [totalUpload] where uploaded data is stored.
  Stats({
    required this.totalDownload,
    required this.totalUpload,
  });

  /// Method [toJson] to convert the class to JSON.
  Map<String, dynamic> toJson() => {
        'totalDownload': totalDownload,
        'totalUpload': totalUpload,
      };

  /// Method [Stats.fromJson] to convert the JSON to class.
  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalDownload: json['totalDownload'] as num,
      totalUpload: json['totalUpload'] as num,
    );
  }
}
