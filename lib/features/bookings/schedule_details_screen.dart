import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date/time formatting
class ScheduleDetailsScreen extends StatefulWidget {
  final String serviceType;
  final String selectedPetId; // We receive the selected pet's ID

  const ScheduleDetailsScreen({
    super.key,
    required this.serviceType,
    required this.selectedPetId,
  });

  @override
  State<ScheduleDetailsScreen> createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _instructionsController = TextEditingController();

  // For Boarding, you might need a second date picker for end date
  DateTime? _selectedEndDate;

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  // --- Date Picker ---  
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Cannot pick a date in the past
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Up to 2 years from now
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        // If start date changes and it's after end date, clear end date
        if (_selectedEndDate != null && _selectedDate!.isAfter(_selectedEndDate!)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  // --- End Date Picker (Specific for Boarding) ---
  Future<void> _pickEndDate(BuildContext context) async {
    if (widget.serviceType != 'Boarding') return; // Only for Boarding

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? _selectedDate ?? DateTime.now(),
      firstDate: _selectedDate ?? DateTime.now(), // End date cannot be before start date
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        _selectedEndDate = pickedDate;
      });
    }
  }

  // --- Time Picker ---
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // --- Validate and Continue ---
  bool _canProceed() {
    // All services require a start date
    if (_selectedDate == null) return false;
    
    // Services other than boarding require a time
    if (widget.serviceType != 'Boarding' && _selectedTime == null) return false;

    // Boarding requires an end date (can be same as start date for single day boarding)
    if (widget.serviceType == 'Boarding' && _selectedEndDate == null) return false;

    return true;
  }

  void _onContinue() {
    if (!_canProceed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all required date/time details.')),
      );
      return;
    }

    // Prepare data to pass to the confirmation screen
    final bookingDetails = {
      'serviceType': widget.serviceType,
      'selectedPetId': widget.selectedPetId,
      'selectedDate': _selectedDate!.toIso8601String(), // ISO 8601 string for easy parsing
      'selectedTime': _selectedTime != null ? '${_selectedTime!.hour}:${_selectedTime!.minute}' : null,
      'selectedEndDate': _selectedEndDate?.toIso8601String(), // Only for boarding
      'specialInstructions': _instructionsController.text.trim(),
    };

    // TODO: Navigate to BookingConfirmationScreen
    context.push(
      '/book/select-pet/${widget.serviceType}/schedule/confirm', // Navigate to the new route
      extra: bookingDetails, // Pass all collected details
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _selectedDate == null
        ? 'Select Date'
        : DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!);
    
    String formattedEndDate = _selectedEndDate == null
        ? 'Select End Date (for boarding)'
        : DateFormat('EEEE, MMM d, yyyy').format(_selectedEndDate!);

    String formattedTime = _selectedTime == null
        ? 'Select Time'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule ${widget.serviceType}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For your ${widget.serviceType} booking:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(formattedDate),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 16),

            // Conditional End Date Selection for Boarding
            if (widget.serviceType == 'Boarding') ...[
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: Text(formattedEndDate),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _pickEndDate(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Please select both a start and end date for boarding. For a single-day stay, select the same date for both.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),
            ],

            // Time Selection (Not strictly required for boarding, but good for drop-off/pickup)
            // You might make this optional or required based on serviceType
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(formattedTime),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _pickTime(context),
            ),
            const SizedBox(height: 24),

            // Special Instructions
            Text(
              'Special Instructions (Optional):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'e.g., "Molly gets anxious around large dogs", "Preferred grooming style"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Continue Button
            ElevatedButton(
              onPressed: _canProceed() ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Confirm Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}