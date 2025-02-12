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

  void addCharacter() {
    final String name = nameController.text.trim();
    final int? initiativeValue = int.tryParse(initiativeController.text.trim());

    if (name.isEmpty || initiativeValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Please enter a valid name and a two-digit initiative.'),
        ),
      );
      return;
    }

    final newCharacter = Character(name: name, initiative: initiativeValue);
    widget.onAdd(newCharacter);
    nameController.clear();
    initiativeController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    initiativeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add character",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              // Expanded field for the character name.
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Character name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              // Fixed-width field for the two-digit initiative.
              Container(
                width: 60,
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
              // Checkmark to confirm adding the character.
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
