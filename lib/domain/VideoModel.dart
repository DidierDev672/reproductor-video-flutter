import 'package:isar/isar.dart';

part 'VideoModel.g.dart';

@collection
class VideoModel {
  Id id = Isar.autoIncrement;

  String title;
  String videoUrl;
  int duration; // En segundos.
  DateTime? lastPlayer;
  bool isFavorite;
  String? thumbnailPath;

  VideoModel({
    required this.title,
    required this.videoUrl,
    required this.duration,
    this.lastPlayer,
    this.isFavorite = false,
  });
}
