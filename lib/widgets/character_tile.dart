import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final int index;
  final bool isActive;
  final bool isPendingDeletion;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onAttack;
  final VoidCallback onDelete;

  const CharacterTile({
    Key? key,
    required this.character,
    required this.index,
    required this.isActive,
    required this.isPendingDeletion,
    required this.onTap,
    required this.onLongPress,
    required this.onAttack,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isActive ? 10 : 2,
      color: isActive ? theme.colorScheme.primary.withOpacity(0.35) : theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: _buildLeadingAvatar(theme),
        title: _buildTitleText(theme),
        subtitle: _buildSubtitle(theme),
        trailing: _buildTrailingIcons(),
      ),
    );
  }

  /// Builds the circular avatar with index number
  Widget _buildLeadingAvatar(ThemeData theme) {
    return CircleAvatar(
      backgroundColor: isActive ? theme.colorScheme.primary.withOpacity(0.8) : theme.colorScheme.secondary,
      child: Text(
        '${index + 1}',
        style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Builds the character name text styling
  Widget _buildTitleText(ThemeData theme) {
    return Text(
      character.name,
      style: TextStyle(
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        color: isActive ? Colors.white : theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  /// Builds the subtitle section containing initiative & HP
  Widget _buildSubtitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Initiative: ${character.initiative}',
          style: TextStyle(color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color),
        ),
        Text(
          'HP: ${character.currentHp}/${character.maxHp}',
          style: TextStyle(color: isActive ? Colors.white : theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  /// Builds the action icons (attack & delete)
  Widget _buildTrailingIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: ImageIcon(AssetImage('assets/icons/sword.png'), color: Colors.orange),
          onPressed: onAttack,
        ),
        IconButton(
          icon: isPendingDeletion
              ? Icon(Icons.check, size: 30, color: Colors.redAccent)
              : Icon(Icons.close, color: Colors.red),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
