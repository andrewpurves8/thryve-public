class WorkoutMetadata {
  Duration? restDuration; // null if no active rest
  bool restPaused;
  DateTime? restEndTime; // null if no active rest

  WorkoutMetadata({
    this.restDuration,
    this.restPaused = false,
    this.restEndTime,
  });

  factory WorkoutMetadata.fromMap(
    Map<String, dynamic> map,
  ) {
    final restDurationSeconds = map['restDurationSeconds'];
    final restEndTime = map['restEndTime'];
    return WorkoutMetadata(
      restDuration: restDurationSeconds == null
          ? null
          : Duration(seconds: restDurationSeconds as int),
      restPaused: map['restPaused'] as bool,
      restEndTime:
          restEndTime == null ? null : DateTime.parse(restEndTime as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'restDurationSeconds': restDuration?.inSeconds,
        'restPaused': restPaused,
        'restEndTime': restEndTime?.toIso8601String(),
      };
}
