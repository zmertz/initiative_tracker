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
      characters.sort(compareCharactersByInitiative);
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
      characters.sort(compareCharactersByInitiative);
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
      characters.sort(compareCharactersByInitiative);
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

  int compareCharactersByInitiative(Character a, Character b) {
    // Treat null initiative as 0 for sorting purposes
    int initiativeA = a.initiative ?? 0;
    int initiativeB = b.initiative ?? 0;
    return initiativeB.compareTo(initiativeA); // Sort descending
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

  void _showNoTemplateAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("No template characters available."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateCharactersDialog(BuildContext context, List<Character> templates) {
    showDialog(
      context: context,
      builder: (context) {
        Character? selectedTemplate;
        TextEditingController nameController = TextEditingController();
        TextEditingController initiativeController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Import Template Character"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Template Selection
                    Column(
                      children: templates.map((character) {
                        return RadioListTile<Character>(
                          title: Text(character.name),
                          value: character,
                          groupValue: selectedTemplate,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedTemplate = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    // Name and Initiative Inputs side by side
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          // Character Name Input
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  hintText: selectedTemplate?.name ?? 'Enter name',
                                ),
                              ),
                            ),
                          ),
                          // Initiative Input
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextField(
                                controller: initiativeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Initiative',
                                  hintText: selectedTemplate?.initiative?.toString() ?? 'Enter initiative',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  onPressed: selectedTemplate == null
                      ? null
                      : () {
                          final newCharacter = Character(
                            name: nameController.text.isEmpty
                                ? selectedTemplate!.name
                                : nameController.text,
                            initiative: initiativeController.text.isEmpty
                                ? selectedTemplate!.initiative ?? 0
                                : int.tryParse(initiativeController.text) ?? 0,
                            maxHp: selectedTemplate!.maxHp,
                            currentHp: selectedTemplate!.maxHp,
                            armorClass: selectedTemplate!.armorClass,
                            actions: selectedTemplate!.actions != null
                                ? List<String>.from(selectedTemplate!.actions!)
                                : null,
                          );
                          addCharacter(newCharacter);
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTemplate != null
                        ? Colors.green // Green when a template is selected
                        : Colors.grey, // Grey when no template is selected
                  ),
                  child: Text("Import"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _importCharacterFromTemplate(BuildContext context) async {
    final templateBox = Hive.box('characterTemplatesBox');
    final List<Character> templates = templateBox.values.cast<Character>().toList();

    if (templates.isEmpty) {
      _showNoTemplateAvailableDialog();
      return;
    }
    _showTemplateCharactersDialog(context, templates);
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
              SizedBox(width: 16), // Adds space between the buttons
              ElevatedButton(
                onPressed: () => _importCharacterFromTemplate(context),
                child: Text("Import Template"),
              ),
            ],
          ),
        ),


        ],
      ),
    );
  }
}
