class Stats {
  final num totalDownload;
  final num totalUpload;

  Stats({
    required this.totalDownload,
    required this.totalUpload,
  });

  Map<String, dynamic> toJson() => {
        'totalDownload': totalDownload,
        'totalUpload': totalUpload,
      };

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalDownload: json['totalDownload'] as num,
      totalUpload: json['totalUpload'] as num,
    );
  }
}
