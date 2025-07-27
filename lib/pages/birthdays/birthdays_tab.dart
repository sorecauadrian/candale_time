import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/birthday.dart';
import 'birthday_form_page.dart';
import 'birthday_detail_page.dart';

class BirthdaysTab extends StatefulWidget {
  const BirthdaysTab({super.key});

  @override
  State<BirthdaysTab> createState() => _BirthdaysTabState();
}

class _BirthdaysTabState extends State<BirthdaysTab> {
  late final Box<Birthday> birthdayBox;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    birthdayBox = Hive.box<Birthday>('birthdays');
  }

  List<Birthday> _birthdaysForDay(DateTime day) => birthdayBox.values
      .where((b) => b.date.month == day.month && b.date.day == day.day)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                headerStyle: const HeaderStyle(formatButtonVisible: false),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, _) {
                    if (_birthdaysForDay(date).isNotEmpty) {
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
                        children: _birthdaysForDay(_selectedDay!).map((b) {
                          return ListTile(
                            title: Text(
                                '${b.name} (${b.ageAt(_selectedDay!) ?? '?'})'),
                            subtitle: Text('Relation: ${b.relation}'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BirthdayDetailPage(birthday: b),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BirthdayFormPage(birthday: b),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => b.delete(),
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
        tooltip: 'Add Birthday',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BirthdayFormPage(
                initialDate: _selectedDay,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
