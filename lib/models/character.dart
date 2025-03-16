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

  @HiveField(4)
  int? armorClass; // Optional field for armor class

  @HiveField(5)
  List<String>? actions; // Optional list of actions

  Character({
    required this.name,
    required this.initiative,
    required this.currentHp,
    required this.maxHp,
    this.armorClass,
    this.actions,
  });
}
