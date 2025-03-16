import 'package:flutter/material.dart';
import '../models/character.dart';

class AddCharacterForm extends StatefulWidget {
  final Function(Character) onAdd;
  final VoidCallback onCancel; // Callback for cancel action

  const AddCharacterForm({
    Key? key,
    required this.onAdd,
    required this.onCancel,
  }) : super(key: key);

  @override
  _AddCharacterFormState createState() => _AddCharacterFormState();
}

class _AddCharacterFormState extends State<AddCharacterForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController initiativeController = TextEditingController();
  final TextEditingController hpController = TextEditingController(); // Single HP field
  final TextEditingController armorClassController = TextEditingController(); // Armor Class field

  // To hold the list of actions
  List<TextEditingController> actionControllers = [];

  void addCharacter() {
    final String name = nameController.text.trim();
    final int? initiativeValue =
        int.tryParse(initiativeController.text.trim());
    final int? hpValue = int.tryParse(hpController.text.trim());
    final String armorClassText = armorClassController.text.trim();
    final int? armorClassValue = armorClassText.isNotEmpty
        ? int.tryParse(armorClassText)
        : null;

    if (name.isEmpty || initiativeValue == null || hpValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid name, initiative, and HP.'),
        ),
      );
      return;
    }

    // Collect all actions from the controllers
    List<String> actions = actionControllers
        .map((controller) => controller.text.trim())
        .where((action) => action.isNotEmpty)
        .toList();

    // When a new character is added, current HP equals max HP.
    final newCharacter = Character(
      name: name,
      initiative: initiativeValue,
      maxHp: hpValue,
      currentHp: hpValue,
      armorClass: armorClassValue, // Add armor class to the character
      actions: actions, // Add actions to the character
    );
    widget.onAdd(newCharacter);

    // Clear all fields after adding.
    nameController.clear();
    initiativeController.clear();
    hpController.clear();
    armorClassController.clear(); // Clear armor class
    // Clear actions
    actionControllers.forEach((controller) => controller.clear());
  }

  // Function to add a new action field
  void addActionField() {
    setState(() {
      actionControllers.add(TextEditingController());
    });
  }

  // Function to remove an action field
  void removeActionField(int index) {
    setState(() {
      actionControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    initiativeController.dispose();
    hpController.dispose();
    armorClassController.dispose(); // Dispose armor class controller
    // Dispose action controllers
    actionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the entire form scrollable
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Character",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Character Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Character Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // HP Field
            TextField(
              controller: hpController,
              decoration: InputDecoration(
                labelText: 'HP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Initiative Field
            TextField(
              controller: initiativeController,
              decoration: InputDecoration(
                labelText: 'Initiative',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            // Armor Class Field (Optional)
            TextField(
              controller: armorClassController,
              decoration: InputDecoration(
                labelText: 'Armor Class (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),

            // Optional Action Fields Section
            Text(
              "Actions (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            // ListView of action fields
            Column(
              children: List.generate(actionControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: actionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Action ${index + 1}',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline, // Allow multiline input
                        maxLines: 10, // Allow up to 10 lines
                        minLines: 1, // Start with 1 line
                        // Use a scrollable area after 10 lines
                        scrollPadding: EdgeInsets.all(20), // Adds padding for scrolling
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => removeActionField(index),
                    ),
                  ],
                );
              }),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: addActionField,
              child: Text('Add Action'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            SizedBox(height: 24),

            // Buttons for Adding or Canceling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel, // Handles the cancel action
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: addCharacter, // Handles the add action
                  child: Text('Add Character'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
