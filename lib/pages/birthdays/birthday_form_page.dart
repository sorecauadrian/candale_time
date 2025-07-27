import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../models/birthday.dart';
import '../../models/gift_idea.dart';
import '../gifts/gift_idea_form_page.dart';

class BirthdayFormPage extends StatefulWidget {
  final Birthday? birthday;
  final DateTime? initialDate;
  const BirthdayFormPage({super.key, this.birthday, this.initialDate});

  @override
  State<BirthdayFormPage> createState() => _BirthdayFormPageState();
}

class _BirthdayFormPageState extends State<BirthdayFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _relationCtrl;
  late final TextEditingController _yearCtrl;
  DateTime _bday = DateTime.now();

  late final Box<GiftIdea> giftBox;
  late Set<int> selectedGiftIds;

  @override
  void initState() {
    super.initState();
    final b = widget.birthday;

    _nameCtrl     = TextEditingController(text: b?.name ?? '');
    _relationCtrl = TextEditingController(text: b?.relation ?? '');
    _yearCtrl     = TextEditingController(text: b?.birthYear?.toString() ?? '');

    _bday = b?.date ?? widget.initialDate ?? DateTime.now();

    giftBox         = Hive.box<GiftIdea>('gift_ideas');
    selectedGiftIds = Set<int>.from(b?.giftIdeaKeys ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _bday,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _bday = d);
  }

  /* picker copied from BirthdayDetailPage */
  Future<void> _showGiftPicker() async {
    // if no gifts exist → jump to create form
    if (giftBox.isEmpty) {
      final g = await Navigator.push<GiftIdea>(
        context,
        MaterialPageRoute(builder: (_) => const GiftIdeaFormPage()),
      );
      if (g != null) setState(() => selectedGiftIds.add(g.key as int));
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Select gift ideas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Create new',
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final g = await Navigator.push<GiftIdea>(
                          context,
                          MaterialPageRoute(builder: (_) => const GiftIdeaFormPage()),
                        );
                        if (g != null) setS(() {});
                      },
                    )
                  ],
                ),
                const Divider(),
                Flexible(
                  child: ListView(
                    children: giftBox.values.map((gift) {
                      final id = gift.key as int;
                      return CheckboxListTile(
                        value: selectedGiftIds.contains(id),
                        title: Text(gift.description),
                        subtitle: gift.notes != null ? Text(gift.notes!) : null,
                        onChanged: (v) => setS(() =>
                            v! ? selectedGiftIds.add(id) : selectedGiftIds.remove(id)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // rebuild main form UI
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final box = Hive.box<Birthday>('birthdays');

    final bday = widget.birthday ?? Birthday(
      name: '', date: _bday, relation: '', giftIdeaKeys: []);
    bday
      ..name        = _nameCtrl.text.trim()
      ..date        = _bday
      ..relation    = _relationCtrl.text.trim()
      ..birthYear   = int.tryParse(_yearCtrl.text.trim())
      ..giftIdeaKeys = selectedGiftIds.toList();

    if (widget.birthday == null) {
      await box.add(bday);
    } else {
      bday.save();
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.birthday == null ? 'Add birthday' : 'Edit birthday'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _relationCtrl,
                  decoration: const InputDecoration(labelText: 'Relation'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearCtrl,
                  decoration: const InputDecoration(labelText: 'Birth year'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final yr = int.tryParse(v);
                    final now = DateTime.now().year;
                    return (yr == null || yr < 1900 || yr > now)
                        ? 'Enter a valid year (1900-$now)'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Birthday:'),
                    TextButton(
                      onPressed: _pickDate,
                      child: Text(DateFormat.yMMMd().format(_bday)),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ListTile(
                  title: const Text('Gift ideas'),
                  subtitle: selectedGiftIds.isEmpty
                  ? const Text('None selected')
                  : Text(selectedGiftIds
                      .map((id) => giftBox.get(id)?.description ?? '…')
                      .join(', ')),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: _showGiftPicker,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      );
}
