import 'package:hive/hive.dart';

part 'gift_idea.g.dart';

@HiveType(typeId: 1)
class GiftIdea extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  bool taken;

  @HiveField(2)
  String? link;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  String? videoLink;

  @HiveField(5)
  String? notes;

  GiftIdea({
    required this.description,
    this.taken = false,
    this.link,
    this.imagePath,
    this.videoLink,
    this.notes,
  });
}
