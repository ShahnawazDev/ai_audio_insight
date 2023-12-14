import 'package:hive/hive.dart';

part 'recording.g.dart';

@HiveType(typeId: 0)
class Recording extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String transcribedText;

  @HiveField(4)
  String summarizedText;

  @HiveField(5)
  final String path;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  String duration;

  Recording(
      {required this.id,
      required this.title,
      required this.description,
      required this.transcribedText,
      required this.summarizedText,
      required this.path,
      required this.date,
      required this.duration});

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      transcribedText: json['transcribedText'],
      summarizedText: json['summarizedText'],
      path: json['path'],
      date: DateTime.parse(json['date']),
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'transcribedText': transcribedText,
        'summarizedText': summarizedText,
        'path': path,
        'date': date.toIso8601String(),
        'duration': duration,
      };

  @override
  String toString() {
    return 'Recording{id: $id, title: $title, description: $description, transcribedText: $transcribedText, summarizedText: $summarizedText, path: $path, date: $date, duration: $duration}';
  }

  Recording copyWith({
    int? id,
    String? title,
    String? description,
    String? transcribedText,
    String? summarizedText,
    String? path,
    DateTime? date,
    String? duration,
  }) {
    return Recording(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      transcribedText: transcribedText ?? this.transcribedText,
      summarizedText: summarizedText ?? this.summarizedText,
      path: path ?? this.path,
      date: date ?? this.date,
      duration: duration ?? this.duration,
    );
  }
}
