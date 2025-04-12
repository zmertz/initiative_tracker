import 'package:flutter/material.dart';
import '../models/character.dart';

class AddCharacterForm extends StatefulWidget {
  final Function(Character) onAdd;
  final VoidCallback onCancel;
  final bool isTemplateScreen; // NEW

  const AddCharacterForm({
    Key? key,
    required this.onAdd,
    required this.onCancel,
    this.isTemplateScreen = false, // NEW: defaults to false
  }) : super(key: key);

  @override
  _AddCharacterFormState createState() => _AddCharacterFormState();
}

class _AddCharacterFormState extends State<AddCharacterForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController initiativeController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController armorClassController = TextEditingController();
  List<TextEditingController> actionControllers = [];

  void addCharacter() {
    final String name = nameController.text.trim();
    final int? hpValue = int.tryParse(hpController.text.trim());
    final int? initiativeValue = widget.isTemplateScreen
        ? null
        : int.tryParse(initiativeController.text.trim());
    final int? armorClassValue = armorClassController.text.trim().isNotEmpty
        ? int.tryParse(armorClassController.text.trim())
        : null;

    if (name.isEmpty || hpValue == null || (!widget.isTemplateScreen && initiativeValue == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid name, HP, and initiative.'),
        ),
      );
      return;
    }

    List<String> actions = actionControllers
        .map((controller) => controller.text.trim())
        .where((action) => action.isNotEmpty)
        .toList();

    final newCharacter = Character(
      name: name,
      initiative: initiativeValue ?? 0,
      maxHp: hpValue,
      currentHp: hpValue,
      armorClass: armorClassValue,
      actions: actions,
    );
    widget.onAdd(newCharacter);

    // Clear fields
    nameController.clear();
    initiativeController.clear();
    hpController.clear();
    armorClassController.clear();
    actionControllers.forEach((controller) => controller.clear());
  }

  void addActionField() {
    setState(() {
      actionControllers.add(TextEditingController());
    });
  }

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
    armorClassController.dispose();
    actionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Character Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: hpController,
              decoration: InputDecoration(
                labelText: 'HP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),

            if (!widget.isTemplateScreen) ...[
              TextField(
                controller: initiativeController,
                decoration: InputDecoration(
                  labelText: 'Initiative',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
            ],

            TextField(
              controller: armorClassController,
              decoration: InputDecoration(
                labelText: 'Armor Class (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),

            Text(
              "Actions (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),

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
                        keyboardType: TextInputType.multiline,
                        maxLines: 10,
                        minLines: 1,
                        scrollPadding: EdgeInsets.all(20),
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
                  onPressed: addCharacter,
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

