/// BackupScheduleDialog
///
/// **Purpose:** Configuration modal for automated backup tasks
/// **State:** StatefulWidget (manages scheduling logic)
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../controllers/backup_controller.dart';
import '../../../../core/constants/backup_constants.dart';

class BackupScheduleDialog extends StatefulWidget {
  final BackupController controller;

  const BackupScheduleDialog({super.key, required this.controller});

  @override
  State<BackupScheduleDialog> createState() => _BackupScheduleDialogState();
}

class _BackupScheduleDialogState extends State<BackupScheduleDialog> {
  final TextEditingController _nameController = TextEditingController();
  BackupFrequency _frequency = BackupFrequency.daily;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 2, minute: 0);
  int? _selectedDayOfWeek;
  int? _selectedDayOfMonth;
  bool _isScheduling = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTextField(
                'Schedule Name',
                _nameController,
                'e.g., Nightly Backup',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Frequency', Icons.repeat),
              _buildFrequencySelector(),
              const SizedBox(height: 20),
              _buildTimePicker(),
              if (_frequency == BackupFrequency.weekly) _buildWeeklySelector(),
              if (_frequency == BackupFrequency.monthly)
                _buildMonthlySelector(),
              const SizedBox(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.schedule, color: AppTheme.secondaryColor),
        ),
        const SizedBox(width: 16),
        const Text(
          'Schedule Backup',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return SegmentedButton<BackupFrequency>(
      segments: const [
        ButtonSegment(value: BackupFrequency.daily, label: Text('Daily')),
        ButtonSegment(value: BackupFrequency.weekly, label: Text('Weekly')),
        ButtonSegment(value: BackupFrequency.monthly, label: Text('Monthly')),
      ],
      selected: {_frequency},
      onSelectionChanged: (val) => setState(() => _frequency = val.first),
    );
  }

  Widget _buildTimePicker() {
    return ListTile(
      title: const Text('Backup Time'),
      subtitle: Text(_selectedTime.format(context)),
      leading: const Icon(Icons.access_time),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) setState(() => _selectedTime = time);
      },
    );
  }

  Widget _buildWeeklySelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 8,
        children: List.generate(7, (i) {
          final day = i + 1;
          return ChoiceChip(
            label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
            selected: _selectedDayOfWeek == day,
            onSelected: (val) =>
                setState(() => _selectedDayOfWeek = val ? day : null),
          );
        }),
      ),
    );
  }

  Widget _buildMonthlySelector() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(labelText: 'Day of Month'),
        initialValue: _selectedDayOfMonth,
        items: List.generate(
          28,
          (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
        ),
        onChanged: (val) => setState(() => _selectedDayOfMonth = val),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ModernSecondaryButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ModernButton(
            text: 'Schedule',
            isLoading: _isScheduling,
            onPressed: _isScheduling ? null : _handleSchedule,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSchedule() async {
    // Basic validation
    if (_nameController.text.isEmpty) return;

    setState(() => _isScheduling = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Backup Scheduled')));
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label, Icons.label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
