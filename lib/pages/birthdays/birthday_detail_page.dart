import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/birthday.dart';
import '../../models/gift_idea.dart';
import 'birthday_form_page.dart';

class BirthdayDetailPage extends StatelessWidget {
  final Birthday birthday;

  const BirthdayDetailPage({super.key, required this.birthday});

  @override
  Widget build(BuildContext context) {
    final age = birthday.ageAt(DateTime.now());
    final giftBox = Hive.box<GiftIdea>('gift_ideas');
    final assignedGifts = (birthday.giftIdeaKeys ?? [])
      .map((key) => giftBox.get(key))
      .whereType<GiftIdea>()
      .toList();


    return Scaffold(
      appBar: AppBar(
        title: Text(birthday.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedBirthday = await Navigator.push<Birthday>(
                context,
                MaterialPageRoute(
                  builder: (_) => BirthdayFormPage(birthday: birthday),
                ),
              );
              if (updatedBirthday != null) {
                birthday
                  ..name = updatedBirthday.name
                  ..date = updatedBirthday.date
                  ..relation = updatedBirthday.relation
                  ..birthYear = updatedBirthday.birthYear
                  ..giftIdeaKeys = updatedBirthday.giftIdeaKeys
                  ..save();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Relation: ${birthday.relation}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Birthday: ${birthday.date.day}/${birthday.date.month}'),
            if (age != null) Text('Turning: $age'),
            const Divider(height: 32),
            Text('Gift Ideas:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (assignedGifts.isEmpty)
              const Text('No gift ideas assigned.')
            else
              ...assignedGifts.map((gift) => ListTile(
                    title: Text(gift.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (gift.notes != null) Text(gift.notes!),
                        if (gift.link != null) Text('🔗 ${gift.link}'),
                      ],
                    ),
                    trailing: gift.taken ? const Icon(Icons.check, color: Colors.green) : null,
                  )),
          ],
        ),
      ),
    );
  }
}
