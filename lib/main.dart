import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/birthday.dart';
import 'models/gift_idea.dart';
import 'pages/birthdays/birthdays_tab.dart';
import 'pages/gifts/gift_ideas_tab.dart';
import 'pages/birthdays/birthday_form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BirthdayAdapter());
  Hive.registerAdapter(GiftIdeaAdapter());

  await Future.wait([
    Hive.openBox<Birthday>('birthdays'),
    Hive.openBox<GiftIdea>('gift_ideas'),
  ]);

  runApp(const CandaleTimeApp());
}

class CandaleTimeApp extends StatelessWidget {
  const CandaleTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candale Time',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const HomeTabs(),
      routes: {
        '/edit-birthday': (context) {
          final birthday = ModalRoute.of(context)!.settings.arguments as Birthday;
          return BirthdayFormPage(birthday: birthday);
        },
      },
    );
  }
}


class HomeTabs extends StatelessWidget {
  const HomeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Candale Time'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.cake), text: 'Birthdays'),
              Tab(icon: Icon(Icons.card_giftcard), text: 'Gifts'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            BirthdaysTab(),
            GiftIdeasTab(),
          ],
        ),
      ),
    );
  }
}
