import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/gift_idea.dart';
import 'gift_idea_form_page.dart';

class GiftIdeasTab extends StatefulWidget {
  const GiftIdeasTab({super.key});

  @override
  State<GiftIdeasTab> createState() => _GiftIdeasTabState();
}

class _GiftIdeasTabState extends State<GiftIdeasTab> {
  late final Box<GiftIdea> giftBox;

  @override
  void initState() {
    super.initState();
    giftBox = Hive.box<GiftIdea>('gift_ideas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: giftBox.listenable(),
        builder: (context, Box<GiftIdea> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No gift ideas yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final gift = box.getAt(index);
              if (gift == null) return const SizedBox.shrink();

              return ListTile(
                title: Text(gift.description),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (gift.notes != null) Text(gift.notes!),
                    if (gift.link != null) Text('🔗 ${gift.link}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => gift.delete(),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GiftIdeaFormPage(giftIdea: gift),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GiftIdeaFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
