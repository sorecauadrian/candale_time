import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/gift_idea.dart';

class GiftIdeaFormPage extends StatefulWidget {
  final GiftIdea? giftIdea;

  const GiftIdeaFormPage({super.key, this.giftIdea});

  @override
  State<GiftIdeaFormPage> createState() => _GiftIdeaFormPageState();
}

class _GiftIdeaFormPageState extends State<GiftIdeaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  late final TextEditingController _imagePathController;
  late final TextEditingController _videoLinkController;
  late final TextEditingController _notesController;
  bool _taken = false;

  @override
  void initState() {
    super.initState();
    final gift = widget.giftIdea;
    _descriptionController = TextEditingController(text: gift?.description ?? '');
    _linkController = TextEditingController(text: gift?.link ?? '');
    _imagePathController = TextEditingController(text: gift?.imagePath ?? '');
    _videoLinkController = TextEditingController(text: gift?.videoLink ?? '');
    _notesController = TextEditingController(text: gift?.notes ?? '');
    _taken = gift?.taken ?? false;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _linkController.dispose();
    _imagePathController.dispose();
    _videoLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveGiftIdea() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<GiftIdea>('gift_ideas');
    final newGift = GiftIdea(
      description: _descriptionController.text.trim(),
      taken: _taken,
      link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
      imagePath: _imagePathController.text.trim().isEmpty ? null : _imagePathController.text.trim(),
      videoLink: _videoLinkController.text.trim().isEmpty ? null : _videoLinkController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.giftIdea != null) {
      widget.giftIdea!
        ..description = newGift.description
        ..taken = newGift.taken
        ..link = newGift.link
        ..imagePath = newGift.imagePath
        ..videoLink = newGift.videoLink
        ..notes = newGift.notes
        ..save();
    } else {
      await box.add(newGift);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.giftIdea != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Gift Idea' : 'Add Gift Idea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _taken,
                onChanged: (val) => setState(() => _taken = val ?? false),
                title: const Text('Already taken'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Link (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagePathController,
                decoration: const InputDecoration(labelText: 'Image path (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _videoLinkController,
                decoration: const InputDecoration(labelText: 'Video link (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveGiftIdea,
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
