// lib/widgets/add_character_form.dart
import 'package:flutter/material.dart';
import '../models/character.dart';

class AddCharacterForm extends StatefulWidget {
  final Function(Character) onAdd;

  const AddCharacterForm({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddCharacterFormState createState() => _AddCharacterFormState();
}

class _AddCharacterFormState extends State<AddCharacterForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController initiativeController = TextEditingController();
  final TextEditingController hpController = TextEditingController(); // Single HP field

  void addCharacter() {
    final String name = nameController.text.trim();
    final int? initiativeValue =
        int.tryParse(initiativeController.text.trim());
    final int? hpValue = int.tryParse(hpController.text.trim());

    if (name.isEmpty || initiativeValue == null || hpValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please enter a valid name, initiative, and HP.'),
        ),
      );
      return;
    }

    // When a new character is added, current HP equals max HP.
    final newCharacter = Character(
      name: name,
      initiative: initiativeValue,
      maxHp: hpValue,
      currentHp: hpValue,
    );
    widget.onAdd(newCharacter);

    // Clear all fields after adding.
    nameController.clear();
    initiativeController.clear();
    hpController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    initiativeController.dispose();
    hpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add character",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Character name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              // Initiative input with a fixed width.
              Container(
                width: 80,
                child: TextField(
                  controller: initiativeController,
                  decoration: InputDecoration(
                    hintText: 'Init',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              // HP input with a fixed width similar to initiative.
              Container(
                width: 80,
                child: TextField(
                  controller: hpController,
                  decoration: InputDecoration(
                    hintText: 'HP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 8),
              // Checkmark icon to confirm adding the character.
              IconButton(
                icon: Icon(Icons.check, color: Colors.green, size: 32),
                onPressed: addCharacter,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
