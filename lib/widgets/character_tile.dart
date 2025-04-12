import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterTile extends StatefulWidget {
  final Character character;
  final int index;
  final bool isActive;
  final bool isPendingDeletion;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onHeal;
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
    required this.onHeal,
    required this.onAttack,
    required this.onDelete,
  }) : super(key: key);

  @override
  _CharacterTileState createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  bool _isExpanded = false; // To track if the dropdown is expanded

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: widget.isActive ? 10 : 2,
      color: widget.isActive ? theme.colorScheme.primary.withOpacity(0.35) : theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            leading: _buildLeadingAvatar(theme),
            title: _buildTitleText(theme),
            subtitle: _buildSubtitle(theme),
            trailing: _buildTrailingIcons(),
          ),
          if (_isExpanded) _buildExpandedInfo(), // Show expanded info if expanded is true
        ],
      ),
    );
  }

  // Builds the circular avatar with initiative number
  Widget _buildLeadingAvatar(ThemeData theme) {
    return CircleAvatar(
      backgroundColor: widget.isActive
          ? theme.colorScheme.primary.withOpacity(0.8)
          : theme.colorScheme.secondary,
      child: Text(
        '${widget.character.initiative ?? '-'}', // Show initiative or a dash if null
        style: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  // Builds the character name text styling
  Widget _buildTitleText(ThemeData theme) {
    return Text(
      widget.character.name,
      style: TextStyle(
        fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
        color: widget.isActive ? Colors.white : theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  // Builds the subtitle section containing initiative & HP
  Widget _buildSubtitle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'HP: ${widget.character.currentHp}/${widget.character.maxHp}',
          style: TextStyle(color: widget.isActive ? Colors.white : theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  // Builds the action icons (attack & delete) along with the drop-down arrow
  Widget _buildTrailingIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Move the drop-down arrow here
        IconButton(
          icon: Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle the expanded state
            });
          },
        ),
        IconButton(
          icon: ImageIcon(AssetImage('assets/icons/heal.png'), color: Colors.green),
          onPressed: widget.onHeal,
        ),
        IconButton(
          icon: ImageIcon(AssetImage('assets/icons/sword.png'), color: Colors.orange),
          onPressed: widget.onAttack,
        ),
        IconButton(
          icon: widget.isPendingDeletion
              ? Icon(Icons.check, size: 30, color: Colors.redAccent)
              : Icon(Icons.close, color: Colors.red),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  // Builds the expanded character information
  Widget _buildExpandedInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Armor Class if available
          if (widget.character.armorClass != null)
            Text(
              "Armor Class: ${widget.character.armorClass}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 8),
          // Display actions if available
          if (widget.character.actions != null && widget.character.actions!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.character.actions!
                  .map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          '• $action',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ))
                  .toList(),
            ),
          // If no actions are available, display this message
          if (widget.character.actions == null || widget.character.actions!.isEmpty)
            Text(
              'No actions available',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
