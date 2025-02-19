import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/character.dart';
import '../widgets/character_tile.dart';
import '../widgets/add_character_form.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/shake_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InitiativeTrackerScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool? isDarkTheme;

  const InitiativeTrackerScreen({
    Key? key,
    this.onThemeChanged,
    this.isDarkTheme,
  }) : super(key: key);

  @override
  _InitiativeTrackerScreenState createState() =>
      _InitiativeTrackerScreenState();
}

class _InitiativeTrackerScreenState extends State<InitiativeTrackerScreen> {
  List<Character> characters = [
    Character(name: "Alice", initiative: 15, currentHp: 15, maxHp: 15),
    Character(name: "Bob", initiative: 12, currentHp: 12, maxHp: 12),
    Character(name: "Charlie", initiative: 18, currentHp: 18, maxHp: 18),
    Character(name: "Dragon", initiative: 10, currentHp: 40, maxHp: 40),
    Character(name: "Roger", initiative: 9, currentHp: 9, maxHp: 9),
  ];

  int currentTurn = 0;
  Set<Character> pendingDeletion = {};

  // List of GlobalKeys for each ShakeWidget wrapping a CharacterTile.
  late List<GlobalKey<ShakeWidgetState>> _shakeKeys;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('encounterBox');
    final savedCharacters = box.get('characters') as List? ?? [];
    final savedTurn = box.get('currentTurn', defaultValue: 0) as int;

    if (savedCharacters.isNotEmpty) {
      characters = savedCharacters.cast<Character>();
      currentTurn = savedTurn;
    } else {
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
    }

    _shakeKeys = List.generate(characters.length, (index) => GlobalKey<ShakeWidgetState>());
  }


  void _saveEncounterState() {
    final box = Hive.box('encounterBox');
    box.put('characters', characters);
    box.put('currentTurn', currentTurn);
  }


  void addCharacter(Character newCharacter) {
    setState(() {
      characters.add(newCharacter);
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
      // Regenerate keys when the character list changes
      _shakeKeys = List.generate(characters.length, (index) => GlobalKey<ShakeWidgetState>());
      _saveEncounterState();
    });
  }

  void removeCharacter(Character character) {
    setState(() {
      int index = characters.indexOf(character);
      characters.remove(character);
      pendingDeletion.remove(character);
      if (characters.isEmpty) {
        currentTurn = 0;
      } else {
        if (index < currentTurn) {
          currentTurn--;
        } else if (currentTurn >= characters.length) {
          currentTurn = 0;
        }
      }
      _shakeKeys = List.generate(characters.length, (index) => GlobalKey<ShakeWidgetState>());
      _saveEncounterState();
    });
  }

  void togglePendingDeletion(Character character) {
    setState(() {
      if (pendingDeletion.contains(character)) {
        removeCharacter(character);
      } else {
        pendingDeletion.add(character);
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            pendingDeletion.remove(character);
          });
        });
      }
    });
  }

  void editCharacter(Character character, 
    {String? newName, int? newInitiative, int? newMaxHp, required int newCurrentHp}) {
    setState(() {
      character.name = newName ?? character.name;
      character.initiative = newInitiative ?? character.initiative;
      character.maxHp = newMaxHp ?? character.maxHp;
      character.currentHp = newCurrentHp;
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
      _saveEncounterState();
    });
  }


  void setActiveCharacter(int index) {
    setState(() {
      currentTurn = index;
      _saveEncounterState();
    });
  }

  void nextTurn() {
    setState(() {
      int index = (currentTurn + 1) % characters.length;
      setActiveCharacter(index);
    });
  }

  void previousTurn() {
    setState(() {
      int index = (currentTurn - 1 + characters.length) % characters.length;
      setActiveCharacter(index);
    });
  }

  void _showEditDialog(Character character) {
    final TextEditingController editNameController =
        TextEditingController(text: character.name);
    final TextEditingController editInitiativeController =
        TextEditingController(text: character.initiative.toString());
    final TextEditingController editMaxHpController =
        TextEditingController(text: character.maxHp.toString());
    final TextEditingController editCurrentHpController =
        TextEditingController(text: character.currentHp.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Character"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editNameController,
                  decoration: InputDecoration(labelText: "Character Name"),
                ),
                TextField(
                  controller: editInitiativeController,
                  decoration: InputDecoration(labelText: "Initiative"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: editMaxHpController,
                  decoration: InputDecoration(labelText: "Max HP"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: editCurrentHpController,
                  decoration: InputDecoration(labelText: "Current HP"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final String newName = editNameController.text.trim();
                final int? newInitiative =
                    int.tryParse(editInitiativeController.text.trim());
                final int? newMaxHp =
                    int.tryParse(editMaxHpController.text.trim());
                final int? newCurrentHp =
                    int.tryParse(editCurrentHpController.text.trim());

                if (newName.isEmpty ||
                    newInitiative == null ||
                    newMaxHp == null ||
                    newCurrentHp == null) {
                  return;
                }
                editCharacter(character, newName: newName, newInitiative: newInitiative,
                    newMaxHp: newMaxHp, newCurrentHp: newCurrentHp);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDamageDialog(Character character) {
    int selectedDamage = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Apply Damage"),
              content: SizedBox(
                height: 150,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: selectedDamage),
                  itemExtent: 40,
                  onSelectedItemChanged: (int value) {
                    selectedDamage = value;
                  },
                  children: List.generate(
                    100,
                    (index) => Center(
                      child: Text(
                        "$index",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDamage == 0) {
                      Navigator.pop(context);
                      return;
                    }
                    setState(() {
                      int newHp = (character.currentHp - selectedDamage) < 0 ? 0 : character.currentHp - selectedDamage;
                      editCharacter(character, newCurrentHp: newHp);
                     // _saveEncounterState();
                    });
                    Navigator.pop(context);
                    // Trigger shake on the affected tile:
                    int index = characters.indexOf(character);
                    if (index != -1 && index < _shakeKeys.length) {
                      _shakeKeys[index].currentState?.shake();
                    }
                  },
                  child: Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "DnD Initiative Tracker",
        onThemeChanged: widget.onThemeChanged,
        isDarkTheme: widget.isDarkTheme,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                bool isActive = index == currentTurn;
                bool isPendingDeletion = pendingDeletion.contains(character);
                return ShakeWidget(
                  key: _shakeKeys[index],
                  child: CharacterTile(
                    character: character,
                    index: index,
                    isActive: isActive,
                    isPendingDeletion: isPendingDeletion,
                    onTap: () {
                      setActiveCharacter(index);
                    },
                    onLongPress: () {
                      _showEditDialog(character);
                    },
                    onAttack: () {
                      _showDamageDialog(character);
                    },
                    onDelete: () {
                      togglePendingDeletion(character);
                    },
                  ),
                );
              },
            ),
          ),
          AddCharacterForm(
            onAdd: addCharacter,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: "Previous Turn",
                  onPressed: previousTurn,
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: nextTurn,
                  child: Text("Next Turn"),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  tooltip: "Next Turn",
                  onPressed: nextTurn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
