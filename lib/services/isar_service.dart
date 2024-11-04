import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player_flutter/domain/VideoModel.dart';

class IsarService {
  static late Isar db;

  Future<void> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [VideoModelSchema],
      directory: dir.path,
    );
  }

  // Guardar video
  Future<void> saveVideo(VideoModel video) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.videoModels.putSync(video));
  }

  // Obtener todos los videos.
  Future<List<VideoModel>> getAllVideos() async {
    final isar = await db;
    return await isar.videoModels.where().findAll();
  }

  // Obtener video pot ID.
  Future<VideoModel?> getVideoById(Id id) async {
    final isar = await db;
    return await isar.videoModels.get(id);
  }

  // Actualizar último reproducido.
  Future<void> updateLastPlayer(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final video = await isar.videoModels.get(id);
      if (video != null) {
        video.lastPlayer = DateTime.now();
        await isar.videoModels.put(video);
      }
    });
  }

  // Marcar/ desmarcar favorito.
  Future<void> toggleFavorite(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final video = await isar.videoModels.get(id);
      if (video != null) {
        video.isFavorite = !video.isFavorite;
        await isar.videoModels.put(video);
      }
    });
  }

  // Obtener video favoritos.
  Future<List<VideoModel>> getFavoriteVideos() async {
    final isar = await db;
    return await isar.videoModels.filter().isFavoriteEqualTo(true).findAll();
  }

  // Eliminar video.
  Future<void> deleteVideo(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.videoModels.delete(id);
    });
  }
}
