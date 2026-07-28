import "package:flutter/material.dart";

import "../../core/theme/app_colors.dart";
import "../../core/theme/app_spacing.dart";
import "widgets/calendar_month_grid.dart";

/// Full-screen monthly calendar used to pick a date for a plan.
///
/// Pure navigation: on confirm, pops itself off the stack and returns the
/// selected [DateTime] to whoever pushed it (see PlannerHomeScreen).
class CalendarScreen extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarScreen({super.key, this.initialDate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Date"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: CalendarMonthGrid(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_selectedDate != null)
                Text(
                  "Selected: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _selectedDate == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedDate),
                child: const Text("Confirm Date"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
