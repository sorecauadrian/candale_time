import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/birthday.dart';
import '../../models/gift_idea.dart';
import 'birthday_form_page.dart';
import '../gifts/gift_idea_form_page.dart';

class BirthdayDetailPage extends StatefulWidget {
  final Birthday birthday;
  const BirthdayDetailPage({super.key, required this.birthday});

  @override
  State<BirthdayDetailPage> createState() => _BirthdayDetailPageState();
}

class _BirthdayDetailPageState extends State<BirthdayDetailPage> {
  late final Box<GiftIdea> giftBox;

  @override
  void initState() {
    super.initState();
    giftBox = Hive.box<GiftIdea>('gift_ideas');
  }

  @override
  Widget build(BuildContext context) {
    final age = widget.birthday.ageAt(DateTime.now());
    final assigned = (widget.birthday.giftIdeaKeys ?? [])
        .map((k) => giftBox.get(k))
        .whereType<GiftIdea>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.birthday.name),
        actions: [
          IconButton(
            tooltip: 'Edit birthday',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BirthdayFormPage(birthday: widget.birthday),
                ),
              );
              if (mounted) setState(() {});
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relation: ${widget.birthday.relation}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Birthday: ${widget.birthday.date.day}/${widget.birthday.date.month}'),
            if (age != null) Text('Turning: $age'),
            const Divider(height: 32),
            Text('Gift Ideas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: assigned.isEmpty
                  ? const Center(child: Text('No gift ideas assigned'))
                  : ListView.builder(
                      itemCount: assigned.length,
                      itemBuilder: (context, i) {
                        final g = assigned[i];
                        // build thumbnails (first image or video icon)
                        Widget leading;
                        if (g.imagePaths.isNotEmpty && File(g.imagePaths.first).existsSync()) {
                          leading = Image.file(File(g.imagePaths.first), width: 56, height: 56, fit: BoxFit.cover);
                        } else if (g.videoPaths.isNotEmpty) {
                          leading = const Icon(Icons.videocam, size: 40);
                        } else {
                          leading = const Icon(Icons.card_giftcard);
                        }
                        return ListTile(
                          leading: leading,
                          title: Text(g.description),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (g.notes != null) Text(g.notes!),
                              if (g.link != null) Text('🔗 ${g.link}'),
                              if (g.imagePaths.length + g.videoPaths.length > 1)
                                Text('${g.imagePaths.length + g.videoPaths.length} attachments'),
                            ],
                          ),
                          trailing: Checkbox(
                            value: g.taken,
                            onChanged: (v) => setState(() {
                              g.taken = v ?? false;
                              g.save();
                            }),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => GiftIdeaFormPage(gift: g)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Assign gifts'),
        onPressed: _showPicker,
      ),
    );
  }

  void _showPicker() async {
    if (giftBox.isEmpty) {
      final ng = await Navigator.push<GiftIdea>(
        context,
        MaterialPageRoute(builder: (_) => const GiftIdeaFormPage()),
      );
      if (ng != null && mounted) {
        setState(() {
          widget.birthday.giftIdeaKeys ??= [];
          widget.birthday.giftIdeaKeys!.add(ng.key as int);
          widget.birthday.save();
        });
      }
      return;
    }

    final sel = Set<int>.from(widget.birthday.giftIdeaKeys ?? []);
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
                    const Text('Select gifts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Create new',
                      onPressed: () async {
                        final g = await Navigator.push<GiftIdea>(
                          context,
                          MaterialPageRoute(builder: (_) => const GiftIdeaFormPage()),
                        );
                        if (g != null) setS(() {});
                      },
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: ListView(
                    children: giftBox.values.map((g) {
                      final id = g.key as int;
                      return CheckboxListTile(
                        value: sel.contains(id),
                        title: Text(g.description),
                        onChanged: (v) => setS(() => v! ? sel.add(id) : sel.remove(id)),
                      );
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.birthday.giftIdeaKeys = sel.toList();
                      widget.birthday.save();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}