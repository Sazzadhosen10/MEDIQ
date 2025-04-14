import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeline extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final ScrollController scrollController;

  const DateTimeline({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.selectedDate,
    required this.onDateSelected,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = endDate.difference(startDate).inDays + 1;
    final DateTime today = DateTime.now();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: days,
        itemBuilder: (context, index) {
          final date = startDate.add(Duration(days: index));
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          Color backgroundColor;
          Color textColor;

          if (isSelected) {
            backgroundColor = Colors.blue.shade900;
            textColor = Colors.white;
          } else if (isToday) {
            backgroundColor = Colors.blue.withOpacity(0.3); // Dimmed
            textColor = Colors.black;
          } else {
            backgroundColor = Colors.white;
            textColor = Colors.black;
          }

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
