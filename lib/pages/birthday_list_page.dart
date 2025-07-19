import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/birthday.dart';
import 'birthday_form_page.dart';

class BirthdayListPage extends StatefulWidget {
  const BirthdayListPage({super.key});

  @override
  State<BirthdayListPage> createState() => _BirthdayListPageState();
}

class _BirthdayListPageState extends State<BirthdayListPage> {
  late final Box<Birthday> birthdayBox;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    birthdayBox = Hive.box<Birthday>('birthdays');
  }

  List<Birthday> _getBirthdaysForDay(DateTime day) {
    return birthdayBox.values
        .where((b) => b.date.month == day.month && b.date.day == day.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candale Time')),
      body: ValueListenableBuilder(
        valueListenable: birthdayBox.listenable(),
        builder: (context, Box<Birthday> box, _) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, _) {
                    final events = _getBirthdaysForDay(date);
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _selectedDay == null
                    ? const Center(child: Text('Select a date to view birthdays'))
                    : ListView(
                        children: _getBirthdaysForDay(_selectedDay!).map((b) {
                          return ListTile(
                            title: Text(b.name),
                            subtitle: Text(
                              'Relation: ${b.relation}'
                              '${b.birthYear != null ? " | Age: ${_selectedDay!.year - b.birthYear!}" : ""}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BirthdayFormPage(birthday: b),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    b.delete();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BirthdayFormPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
