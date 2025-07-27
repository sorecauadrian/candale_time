import 'package:hive/hive.dart';
part 'gift_idea.g.dart';

@HiveType(typeId: 1)
class GiftIdea extends HiveObject {
  @HiveField(0) String description;
  @HiveField(1) bool taken;

  @HiveField(2) String? link;
  @HiveField(3) List<String> imagePaths;
  @HiveField(4) List<String> videoPaths;
  @HiveField(5) String? notes;

  GiftIdea({
    required this.description,
    this.taken = false,
    this.link,
    List<String>? imagePaths,
    List<String>? videoPaths,
    this.notes,
  })  : imagePaths = imagePaths ?? [],
        videoPaths = videoPaths ?? [];
}
