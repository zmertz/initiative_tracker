// lib/models/character.dart
class Character {
  String name;
  int initiative;
  int currentHp;
  int maxHp;

  Character({
    required this.name,
    required this.initiative,
    required this.currentHp,
    required this.maxHp,
  });
}
