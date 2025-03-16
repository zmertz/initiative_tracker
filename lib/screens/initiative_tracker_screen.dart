import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/character.dart';
import '../widgets/character_tile.dart';
import '../widgets/edit_character_form.dart';
import '../widgets/add_character_form.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/status_widget.dart';
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
    Character(name: "Goblin", initiative: 5, currentHp: 7, maxHp: 7),
    Character(name: "Bugbear", initiative: 15, currentHp: 27, maxHp: 27),
    Character(name: "Wolf", initiative: 12, currentHp: 11, maxHp: 11),
  ];

  int currentTurn = 0;
  Set<Character> pendingDeletion = {};

  // List of GlobalKeys for each StatusWidget wrapping a CharacterTile.
  late List<GlobalKey<StatusWidgetState>> _statusKeys;

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

    _statusKeys = List.generate(characters.length, (index) => GlobalKey<StatusWidgetState>());
  }


  void _saveEncounterState() {
    final box = Hive.box('encounterBox');
    box.put('characters', characters);
    box.put('currentTurn', currentTurn);
  }


  void addCharacter(Character newCharacter) {
    const int characterMax = 20;

    if (characters.length >= characterMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("New character exceeds max of $characterMax"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      characters.add(newCharacter);
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
      // Regenerate keys when the character list changes
      _statusKeys = List.generate(characters.length, (index) => GlobalKey<StatusWidgetState>());
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
      _statusKeys = List.generate(characters.length, (index) => GlobalKey<StatusWidgetState>());
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
      {String? newName, int? newInitiative, int? newMaxHp, required int newCurrentHp, int? newArmorClass, List<String>? newActions}) {
    setState(() {
      character.name = newName ?? character.name;
      character.initiative = newInitiative ?? character.initiative;
      character.maxHp = newMaxHp ?? character.maxHp;
      character.currentHp = newCurrentHp;
      character.armorClass = newArmorClass ?? character.armorClass;
      character.actions = newActions ?? character.actions;
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          content: EditCharacterForm(
            character: character,
            onSave: (updatedCharacter) {
              editCharacter(character, 
                newName: updatedCharacter.name, 
                newInitiative: updatedCharacter.initiative, 
                newMaxHp: updatedCharacter.maxHp, 
                newCurrentHp: updatedCharacter.currentHp,
                newArmorClass: updatedCharacter.armorClass,
                newActions: updatedCharacter.actions
              );
              Navigator.pop(context); // Close the dialog after saving
            },
            onCancel: () {
              Navigator.pop(context); // Close the dialog on cancel
            },
          ),
        );
      },
    );
  }


  void _performHpChange(Character character, String changeType) {
    int changeAmount = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: (changeType == "heal") ? Text("Apply Heal") : Text("Apply Damage"),
              content: SizedBox(
                height: 150,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: changeAmount),
                  itemExtent: 40,
                  onSelectedItemChanged: (int value) {
                    changeAmount = value;
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
                    if (changeAmount == 0) {
                      Navigator.pop(context);
                      return;
                    }
                    setState(() {
                      int newHp = character.currentHp;
                      if (changeType == "heal") {
                        newHp = (character.currentHp + changeAmount) > character.maxHp ? character.maxHp : character.currentHp + changeAmount;
                      } else if (changeType == "damage") {
                        newHp = (character.currentHp - changeAmount) < 0 ? 0 : character.currentHp - changeAmount;
                      }
                      editCharacter(character, newCurrentHp: newHp);
                    });
                    Navigator.pop(context);
                    // Trigger glow on the affected tile:
                    if (changeType == "heal") {
                      int index = characters.indexOf(character);
                      if (index != -1 && index < _statusKeys.length) {
                        _statusKeys[index].currentState?.glow();
                      }
                    // Trigger shake on the affected tile:                
                    } else if (changeType == "damage") {
                      int index = characters.indexOf(character);
                      if (index != -1 && index < _statusKeys.length) {
                        _statusKeys[index].currentState?.shake();
                      }
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

  void _showHealDialog(Character character) {
    _performHpChange(character, "heal");
  }

  void _showDamageDialog(Character character) {
    _performHpChange(character, "damage");
  }

 void _showAddCharacterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16.0),
          content: AddCharacterForm(
            onAdd: (newCharacter) {
              addCharacter(newCharacter);
              Navigator.pop(context); // Close the dialog after adding
            },
            onCancel: () {
              Navigator.pop(context); // Close the dialog on cancel
            },
          ),
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
                return StatusWidget(
                  key: _statusKeys[index],
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
                    onHeal: () {
                      _showHealDialog(character);
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _showAddCharacterDialog(context),
                  child: Text("Add Character"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
