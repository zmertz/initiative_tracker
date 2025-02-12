// lib/widgets/character_tile.dart
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme/app_colors.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final int index;
  final bool isActive;
  final bool isPendingDeletion;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const CharacterTile({
    Key? key,
    required this.character,
    required this.index,
    required this.isActive,
    required this.isPendingDeletion,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 8 : 2,
      color: isActive 
        ? AppColors.primary.withValues(alpha: 0.2) 
        : AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: isActive ? AppColors.primary : Colors.blueGrey,
          child: Text(
            '${index + 1}',
            style: TextStyle(color: AppColors.text),
          ),
        ),
        title: Text(
          character.name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          'Initiative: ${character.initiative}',
          style: TextStyle(color: AppColors.text),
        ),
        trailing: IconButton(
          icon: isPendingDeletion
              ? Icon(Icons.check, size: 30, color: Colors.redAccent)
              : Icon(Icons.close, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
