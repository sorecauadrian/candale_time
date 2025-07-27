import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/gift_idea.dart';
import '../viewer/image_viewer_page.dart';
import '../viewer/video_viewer_page.dart';


class GiftIdeaFormPage extends StatefulWidget {
  final GiftIdea? gift;
  const GiftIdeaFormPage({super.key, this.gift});

  @override
  State<GiftIdeaFormPage> createState() => _GiftIdeaFormPageState();
}

class _GiftIdeaFormPageState extends State<GiftIdeaFormPage> {
  final _fKey = GlobalKey<FormState>();
  late final TextEditingController _desc, _notes, _link;
  bool _taken = false;
  late List<String> _imgs;
  late List<String> _vids;

  @override
  void initState() {
    super.initState();
    final g = widget.gift;
    _desc  = TextEditingController(text: g?.description ?? '');
    _notes = TextEditingController(text: g?.notes ?? '');
    _link  = TextEditingController(text: g?.link ?? '');
    _taken = g?.taken ?? false;
    _imgs  = List<String>.from(g?.imagePaths ?? []);
    _vids  = List<String>.from(g?.videoPaths ?? []);
  }

  Future<String> _copyToAppDir(String prefix, String srcPath) async {
    final dir  = await getApplicationDocumentsDirectory();
    final name = '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${srcPath.split('/').last}';
    final dst  = '${dir.path}/$name';
    await File(srcPath).copy(dst);
    return dst;
  }

  Future<void> _addImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final path = await _copyToAppDir('img', x.path);
    setState(() => _imgs.add(path));
  }

  Future<void> _addVideo() async {
    final r = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (r == null) return;
    final path = await _copyToAppDir('vid', r.path);
    setState(() => _vids.add(path));
  }

  Future<void> _save() async {
    if (!_fKey.currentState!.validate()) return;
    final box = Hive.box<GiftIdea>('gift_ideas');
    final g = widget.gift ?? GiftIdea(description: '', taken: false);

    g
      ..description = _desc.text.trim()
      ..notes       = _notes.text.trim().isEmpty ? null : _notes.text.trim()
      ..link        = _link.text.trim().isEmpty ? null : _link.text.trim()
      ..taken       = _taken
      ..imagePaths  = _imgs
      ..videoPaths  = _vids;

    widget.gift == null ? await box.add(g) : await g.save();
    if (mounted) Navigator.pop(context, g);
  }

  Widget _thumb(String path, {required bool isVideo}) => GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isVideo
                ? VideoViewerPage(path: path)
                : ImageViewerPage(path: path),
          ),
        );
      },
      child: Stack(
        children: [
          isVideo
              ? const Icon(Icons.videocam, size: 64)
              : Image.file(File(path), width: 64, height: 64, fit: BoxFit.cover),
          Positioned(
            right: -10,
            top: -10,
            child: IconButton(
              splashRadius: 18,
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(
                () => isVideo ? _vids.remove(path) : _imgs.remove(path),
              ),
            ),
          ),
        ],
      ),
    );

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(title: Text(widget.gift == null ? 'Add gift' : 'Edit gift')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _fKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Enter text' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _link,
                  decoration: const InputDecoration(labelText: 'External link'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 3,
                ),
                const Divider(height: 32),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._imgs.map((p) => _thumb(p, isVideo: false)),
                    ..._vids.map((p) => _thumb(p, isVideo: true)),
                    GestureDetector(
                      onTap: _addImage,
                      child: Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addVideo,
                      child: Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.videocam),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                CheckboxListTile(
                  value: _taken,
                  onChanged: (v) => setState(() => _taken = v ?? false),
                  title: const Text('Already taken'),
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
