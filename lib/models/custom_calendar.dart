import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarView extends StatefulWidget {
  const CustomCalendarView({
    super.key,
    this.minimumDate,
    this.maximumDate,
    this.initialStartDate,
    this.initialEndDate,
    required this.startEndDateChange,
  });

  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final void Function(DateTime startDate, DateTime endDate) startEndDateChange;

  @override
  State<CustomCalendarView> createState() => _CustomCalendarViewState();
}

class _CustomCalendarViewState extends State<CustomCalendarView> {
  static DateTime _normalize(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  late DateTime _firstDay;
  late DateTime _lastDay;
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _firstDay = widget.minimumDate != null
        ? _normalize(widget.minimumDate!)
        : _normalize(DateTime(now.year - 1, now.month, now.day));
    _lastDay = widget.maximumDate != null
        ? _normalize(widget.maximumDate!)
        : _normalize(DateTime(now.year + 2, now.month, now.day));
    _focusedDay = widget.initialStartDate != null
        ? _normalize(widget.initialStartDate!)
        : _normalize(now);
    if (widget.initialStartDate != null) {
      _rangeStart = _normalize(widget.initialStartDate!);
    }
    if (widget.initialEndDate != null) {
      _rangeEnd = _normalize(widget.initialEndDate!);
    }
  }

  void _notifyRange() {
    if (_rangeStart != null && _rangeEnd != null) {
      widget.startEndDateChange(_rangeStart!, _rangeEnd!);
    } else if (_rangeStart != null) {
      widget.startEndDateChange(_rangeStart!, _rangeStart!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode: RangeSelectionMode.enforced,
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          if (_rangeStart == null || _rangeEnd != null) {
            _rangeStart = _normalize(selectedDay);
            _rangeEnd = null;
          } else {
            final start = _rangeStart!;
            final end = _normalize(selectedDay);
            if (end.isBefore(start)) {
              _rangeStart = end;
              _rangeEnd = start;
            } else {
              _rangeEnd = end;
            }
            _notifyRange();
          }
        });
      },
      onRangeSelected: (start, end, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _rangeStart = start;
          _rangeEnd = end ?? start;
          _notifyRange();
        });
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
    );
  }
}
