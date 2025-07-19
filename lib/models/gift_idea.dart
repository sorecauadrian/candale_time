import 'package:hive/hive.dart';

part 'gift_idea.g.dart';

@HiveType(typeId: 1)
class GiftIdea extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  bool isTaken;

  GiftIdea({
    required this.description,
    this.isTaken = false,
  });
}
