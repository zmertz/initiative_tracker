// lib/models/character.dart
import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 0)
class Character {
  @HiveField(0)
  String name;

  @HiveField(1)
  int initiative;

  @HiveField(2)
  int currentHp;

  @HiveField(3)
  int maxHp;

  Character({
    required this.name,
    required this.initiative,
    required this.currentHp,
    required this.maxHp,
  });
}
