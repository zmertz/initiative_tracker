import 'package:hive/hive.dart';

part 'character.g.dart';

@HiveType(typeId: 0)
class Character {
  @HiveField(0)
  String name;

  @HiveField(1)
  int? initiative;

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
    this.initiative,
    required this.currentHp,
    required this.maxHp,
    this.armorClass,
    this.actions,
  });

  Character copyWith({
    String? name,
    int? initiative,
    int? currentHp,
    int? maxHp,
    int? armorClass,
    List<String>? actions,
  }) {
    return Character(
      name: name ?? this.name,
      initiative: initiative ?? this.initiative,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      armorClass: armorClass ?? this.armorClass,
      actions: actions ?? List.from(this.actions ?? []),
    );
  }
}
