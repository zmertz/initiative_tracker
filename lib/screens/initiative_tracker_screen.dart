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
    Character(name: "Alice", initiative: 15),
    Character(name: "Bob", initiative: 12),
    Character(name: "Charlie", initiative: 18),
    Character(name: "Dragon", initiative: 10),
    Character(name: "Roger", initiative: 9),
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
        // Remove the pending state after 3 seconds if no action is taken.
        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            pendingDeletion.remove(character);
          });
        });
      }
    });
  }

  void editCharacter(Character character, String newName, int newInitiative) {
    setState(() {
      character.name = newName;
      character.initiative = newInitiative;
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Character"),
          content: Column(
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
            ],
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
                if (newName.isEmpty || newInitiative == null) {
                  return;
                }
                editCharacter(character, newName, newInitiative);
                Navigator.pop(context);
              },
              child: Text("Save"),
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
