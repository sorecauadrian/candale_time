import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/birthday.dart';

class BirthdayFormPage extends StatefulWidget {
  final Birthday? birthday;

  const BirthdayFormPage({super.key, this.birthday});

  @override
  State<BirthdayFormPage> createState() => _BirthdayFormPageState();
}

class _BirthdayFormPageState extends State<BirthdayFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _birthYearController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final birthday = widget.birthday;
    _nameController = TextEditingController(text: birthday?.name ?? '');
    _relationController = TextEditingController(text: birthday?.relation ?? '');
    _birthYearController = TextEditingController(
        text: birthday?.birthYear?.toString() ?? '');
    _selectedDate = birthday?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _birthYearController.dispose();
    super.dispose();
  }

  void _saveBirthday() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<Birthday>('birthdays');
    final newBirthday = Birthday(
      name: _nameController.text,
      date: _selectedDate,
      relation: _relationController.text,
      birthYear: int.tryParse(_birthYearController.text.trim()),
    );

    if (widget.birthday != null) {
      widget.birthday!
        ..name = newBirthday.name
        ..date = newBirthday.date
        ..relation = newBirthday.relation
        ..birthYear = newBirthday.birthYear
        ..save();
    } else {
      await box.add(newBirthday);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.birthday != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Birthday' : 'Add Birthday'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relation'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _birthYearController,
                decoration: const InputDecoration(labelText: 'Birth Year'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter birth year';
                  final year = int.tryParse(val);
                  if (year == null || year < 1900 || year > DateTime.now().year) {
                    return 'Enter valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Birthday: '),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(DateFormat.yMMMd().format(_selectedDate)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveBirthday,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
