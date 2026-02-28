// lib/presentation/screens/staff/staff_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/presentation/widgets/staff_drawer.dart';
import 'package:intl/intl.dart';

import '../../../data/models/staff_schedule_model.dart';

class StaffScheduleScreen extends StatefulWidget {
  @override
  _StaffScheduleScreenState createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<StaffSchedule> _weeklySchedules = [];
  Map<String, List<StaffSchedule>> _scheduleByDay = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    final provider = Provider.of<StaffProvider>(context, listen: false);
    if (provider.currentUser != null) {
      final schedules = await provider.getSchedulesByStaff(provider.currentUser!.id);
      setState(() {
        _weeklySchedules = schedules;
        _organizeSchedulesByDay();
      });
    }
  }

  void _organizeSchedulesByDay() {
    _scheduleByDay.clear();
    final now = _selectedDate;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);

      final daySchedules = _weeklySchedules.where((s) =>
      s.workDate.year == day.year &&
          s.workDate.month == day.month &&
          s.workDate.day == day.day
      ).toList();

      if (daySchedules.isNotEmpty) {
        _scheduleByDay[dayStr] = daySchedules;
      }
    }
  }

  void _changeWeek(int direction) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: direction * 7));
      _organizeSchedulesByDay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Schedule'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      drawer: StaffDrawer(),
      body: Column(
        children: [
          // Week Navigator
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () => _changeWeek(-1),
                ),
                Column(
                  children: [
                    Text(
                      'Week of ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getWeekRange(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () => _changeWeek(1),
                ),
              ],
            ),
          ),

          // Weekly Schedule Grid
          Expanded(
            child: _weeklySchedules.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text('No schedule available'),
                ],
              ),
            )
                : _buildWeeklyGrid(),
          ),
        ],
      ),
    );
  }

  String _getWeekRange() {
    final start = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final end = start.add(Duration(days: 6));
    return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  Widget _buildWeeklyGrid() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Day Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              return Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8),

          // Date Numbers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final isToday = _isSameDay(date, DateTime.now());
              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.blue[800] : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 20),

          // Schedule Cards by Day
          ...List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final daySchedules = _scheduleByDay[dateStr] ?? [];

            if (daySchedules.isEmpty) {
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                color: Colors.grey[100],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.free_breakfast, color: Colors.grey),
                      SizedBox(width: 12),
                      Text('No shift', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: daySchedules.map((schedule) {
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: schedule.shiftColor,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: schedule.shiftColor.withOpacity(0.1),
                      child: Icon(
                        Icons.access_time,
                        color: schedule.shiftColor,
                      ),
                    ),
                    title: Text(
                      schedule.shift,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: schedule.shiftColor,
                      ),
                    ),
                    subtitle: Text(schedule.shiftTime),
                    trailing: Chip(
                      label: Text(schedule.shift),
                      backgroundColor: schedule.shiftColor.withOpacity(0.1),
                      labelStyle: TextStyle(color: schedule.shiftColor),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}