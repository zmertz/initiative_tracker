import 'package:flutter/material.dart';
import '../models/character.dart';

class EditCharacterForm extends StatefulWidget {
  final Character character;
  final Function(Character) onSave;
  final Function() onCancel;
  final bool isTemplateScreen;

  const EditCharacterForm({
    Key? key,
    required this.character,
    required this.onSave,
    required this.onCancel,
    this.isTemplateScreen = false,
  }) : super(key: key);

  @override
  _EditCharacterFormState createState() => _EditCharacterFormState();
}

class _EditCharacterFormState extends State<EditCharacterForm> {
  late TextEditingController nameController;
  late TextEditingController initiativeController;
  late TextEditingController maxHpController;
  late TextEditingController currentHpController;
  late TextEditingController armorClassController; // Armor Class controller
  List<TextEditingController> actionControllers = []; // List for actions

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.character.name);
    initiativeController = TextEditingController(text: widget.character.initiative.toString());
    maxHpController = TextEditingController(text: widget.character.maxHp.toString());
    currentHpController = TextEditingController(text: widget.character.currentHp.toString());
    armorClassController = TextEditingController(text: widget.character.armorClass?.toString() ?? '');
    actionControllers = widget.character.actions?.map((action) => TextEditingController(text: action)).toList() ?? [];
  }

  @override
  void dispose() {
    nameController.dispose();
    initiativeController.dispose();
    maxHpController.dispose();
    currentHpController.dispose();
    armorClassController.dispose(); // Dispose armor class controller
    // Dispose action controllers
    actionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void saveCharacter() {
    final String newName = nameController.text.trim();
    int? newInitiative = int.tryParse(initiativeController.text.trim());
    final int? newMaxHp = int.tryParse(maxHpController.text.trim());
    int? newCurrentHp = int.tryParse(currentHpController.text.trim());
    final String newArmorClass = armorClassController.text.trim();
    final int? newArmorClassValue = newArmorClass.isNotEmpty ? int.tryParse(newArmorClass) : null;

    if (newInitiative == null) {
      newInitiative = 0;
    }
    if (newCurrentHp == null) {
      newCurrentHp = newMaxHp;
    }

    if (newName.isEmpty || newMaxHp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter valid values for all fields.'),
        ),
      );
      return;
    }

    final updatedCharacter = Character(
      name: newName,
      initiative: newInitiative,
      maxHp: newMaxHp,
      currentHp: newCurrentHp!, // ! asserts that it's not null - needed for int? -> int
      armorClass: newArmorClassValue,
      actions: actionControllers
          .map((controller) => controller.text.trim())
          .where((action) => action.isNotEmpty)
          .toList(),
    );

    widget.onSave(updatedCharacter);
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
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Make the entire form scrollable
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Character",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Character Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Initiative Field
                      if (!widget.isTemplateScreen) ...[
                        // Initiative Field
                        TextFormField(
                          controller: initiativeController,
                          decoration: InputDecoration(
                            labelText: 'Initiative',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                      ],
                      // Max HP Field
                      TextFormField(
                        controller: maxHpController,
                        decoration: InputDecoration(
                          labelText: 'Max HP',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      // Current HP Field
                      if (!widget.isTemplateScreen) ...[
                        // Current HP Field
                        TextFormField(
                          controller: currentHpController,
                          decoration: InputDecoration(
                            labelText: 'Current HP',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                      ]
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Armor Class Field (Optional)
            TextFormField(
              controller: armorClassController,
              decoration: InputDecoration(
                labelText: 'Armor Class (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            // Actions Section
            Text(
              "Actions (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            // ListView of action fields
            Column(
              children: List.generate(actionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: actionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Action ${index + 1}',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 10,
                          minLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => removeActionField(index),
                      ),
                    ],
                  ),
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
            // Buttons for saving or canceling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: saveCharacter,
                  child: Text('Save Character'),
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
