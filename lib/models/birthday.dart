import 'package:hive/hive.dart';
import 'gift_idea.dart';

part 'birthday.g.dart';

@HiveType(typeId: 0)
class Birthday extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String relation;

  @HiveField(3)
  int? birthYear;

  @HiveField(4)
  List<GiftIdea> giftIdeas;

  Birthday({
    required this.name,
    required this.date,
    required this.relation,
    this.birthYear,
    this.giftIdeas = const [],
  });
}
