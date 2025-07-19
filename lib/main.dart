import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'models/birthday.dart';
import 'pages/birthday_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(BirthdayAdapter());
  await Hive.openBox<Birthday>('birthdays');

  runApp(const CandaleTimeApp());
}

class CandaleTimeApp extends StatelessWidget {
  const CandaleTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candale Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const BirthdayListPage(),
    );
  }
}
