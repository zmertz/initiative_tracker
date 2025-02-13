// lib/screens/initiative_tracker_screen.dart
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../widgets/character_tile.dart';
import '../widgets/add_character_form.dart';

class InitiativeTrackerScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    characters.sort((a, b) => b.initiative.compareTo(a.initiative));
  }

  void addCharacter(Character newCharacter) {
    setState(() {
      characters.add(newCharacter);
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
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
    });
  }

  void setActiveCharacter(int index) {
    setState(() {
      currentTurn = index;
    });
  }

  void togglePendingDeletion(Character character) {
    setState(() {
      if (pendingDeletion.contains(character)) {
        // Confirm deletion.
        removeCharacter(character);
      } else {
        pendingDeletion.add(character);
        // Remove pending state after 3 seconds if no action is taken.
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            pendingDeletion.remove(character);
          });
        });
      }
    });
  }

  void editCharacter(Character character, String newName, int newInitiative,
      {required int newMaxHp, required int newCurrentHp}) {
    setState(() {
      character.name = newName;
      character.initiative = newInitiative;
      character.maxHp = newMaxHp;
      character.currentHp = newCurrentHp;
      characters.sort((a, b) => b.initiative.compareTo(a.initiative));
    });
  }

  void nextTurn() {
    setState(() {
      currentTurn = (currentTurn + 1) % characters.length;
    });
  }

  void previousTurn() {
    setState(() {
      currentTurn = (currentTurn - 1 + characters.length) % characters.length;
    });
  }

  /// Private method to show the edit dialog for a character.
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
                editCharacter(character, newName, newInitiative,
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

  /// Private method to show a dialog for applying damage to a character.
  void _showDamageDialog(Character character) {
    final TextEditingController damageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Apply Damage"),
          content: TextField(
            controller: damageController,
            decoration: InputDecoration(hintText: "Enter damage amount"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel damage input.
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final int? damage = int.tryParse(damageController.text.trim());
                if (damage == null || damage < 0) return;
                setState(() {
                  // Subtract damage, but not below 0.
                  character.currentHp =
                      (character.currentHp - damage) < 0 ? 0 : character.currentHp - damage;
                });
                Navigator.pop(context);
              },
              child: Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DnD Initiative Tracker"),
      ),
      body: Column(
        children: [
          // List of characters.
          Expanded(
            child: ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                bool isActive = index == currentTurn;
                bool isPendingDeletion = pendingDeletion.contains(character);
                return CharacterTile(
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
                );
              },
            ),
          ),
          // Add Character form widget.
          AddCharacterForm(
            onAdd: addCharacter,
          ),
          // Navigation buttons.
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
