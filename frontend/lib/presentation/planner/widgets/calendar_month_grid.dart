import "package:flutter/material.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_spacing.dart";

const List<String> _kMonthNames = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

const List<String> _kWeekdayLabels = ["M", "T", "W", "T", "F", "S", "S"];

/// A self-contained monthly calendar grid.
///
/// Handles its own month navigation (prev/next) internally and reports the
/// selected date back through [onDateSelected]. No provider, no API - the
/// displayed month is plain widget state.
class CalendarMonthGrid extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarMonthGrid({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarMonthGrid> createState() => _CalendarMonthGridState();
}

class _CalendarMonthGridState extends State<CalendarMonthGrid> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final base = widget.selectedDate ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    // Monday-first leading blank cells.
    final leadingBlanks = (firstDayOfMonth.weekday - DateTime.monday) % 7;

    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _goToPreviousMonth,
              icon: const Icon(Icons.chevron_left),
              color: AppColors.textPrimary,
            ),
            Text(
              "${_kMonthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: _goToNextMonth,
              icon: const Icon(Icons.chevron_right),
              color: AppColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _kWeekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: leadingBlanks + daysInMonth,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return const SizedBox.shrink();
            }

            final day = index - leadingBlanks + 1;
            final cellDate = DateTime(_visibleMonth.year, _visibleMonth.month, day);
            final isSelected = widget.selectedDate != null && _isSameDay(cellDate, widget.selectedDate!);
            final isToday = _isSameDay(cellDate, today);

            return _DayCell(
              day: day,
              isSelected: isSelected,
              isToday: isToday,
              onTap: () => widget.onDateSelected(cellDate),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: (!isSelected && isToday) ? Border.all(color: AppColors.primary, width: 1.2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          "$day",
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
