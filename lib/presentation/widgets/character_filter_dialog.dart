import 'package:flutter/material.dart';

class CharacterFilterDialog extends StatefulWidget {
  final String? initialName;
  final String? initialStatus;
  final String? initialSpecies;
  final String? initialType;
  final String? initialGender;

  const CharacterFilterDialog({
    super.key,
    this.initialName,
    this.initialStatus,
    this.initialSpecies,
    this.initialType,
    this.initialGender,
  });

  @override
  State<CharacterFilterDialog> createState() => _CharacterFilterDialogState();
}

class _CharacterFilterDialogState extends State<CharacterFilterDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _typeController;
  String? _selectedStatus;
  String? _selectedGender;

  final List<String> _statuses = ['alive', 'dead', 'unknown'];
  final List<String> _genders = ['female', 'male', 'genderless', 'unknown'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _speciesController = TextEditingController(text: widget.initialSpecies);
    _typeController = TextEditingController(text: widget.initialType);
    _selectedStatus = widget.initialStatus;
    _selectedGender = widget.initialGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Characters'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Rick',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _statuses.map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(
                labelText: 'Species',
                hintText: 'e.g. Alien',
                prefixIcon: Icon(Icons.bug_report),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _genders.map((gender) {
                return ChoiceChip(
                  label: Text(gender),
                  selected: _selectedGender == gender,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = selected ? gender : null;
                    });
                  },
                );
              }).toList(),
            ),
             const SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'e.g. Chair',
                prefixIcon: Icon(Icons.category),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'name': _nameController.text.isEmpty ? null : _nameController.text,
              'status': _selectedStatus,
              'species': _speciesController.text.isEmpty ? null : _speciesController.text,
              'gender': _selectedGender,
              'type': _typeController.text.isEmpty ? null : _typeController.text,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
