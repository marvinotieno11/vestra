import 'package:flutter/material.dart';
import 'events_store.dart';

class OccasionsScreen extends StatefulWidget {
  const OccasionsScreen({super.key});

  @override
  State<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends State<OccasionsScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await EventsStore.loadEvents();

    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> get _eventsForSelectedDate {
    return EventsStore.events.where((event) {
      final date = DateTime.tryParse(event['date']?.toString() ?? '');

      if (date == null) {
        return false;
      }

      return date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
    }).toList();
  }

  bool _hasEventOnDate(DateTime date) {
    return EventsStore.events.any((event) {
      final eventDate = DateTime.tryParse(event['date']?.toString() ?? '');

      if (eventDate == null) {
        return false;
      }

      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: gold,
              onPrimary: Colors.black,
              surface: card,
              onSurface: softWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      _focusedMonth = DateTime(picked.year, picked.month);
    });
  }

  Future<void> _showAddEventSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _AddEventSheet(initialDate: _selectedDate);
      },
    );

    if (result == true && mounted) {
      await _loadEvents();
    }
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return weekdays[weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _eventsForSelectedDate;

    return Scaffold(
      backgroundColor: black,

      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'OCCASIONS',
          style: TextStyle(
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        iconTheme: const IconThemeData(color: gold),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dress for it.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Keep track of the moments you want Vestra to style you for.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 26),

              // ---------------------------------------------------------
              // EVENTS COME FIRST
              // ---------------------------------------------------------
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your events',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _pickDate,
                    tooltip: 'Open calendar',
                    icon: const Icon(
                      Icons.calendar_month_outlined,
                      color: gold,
                      size: 23,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (EventsStore.events.isEmpty)
                _buildNoEvents()
              else
                Column(
                  children: EventsStore.events.map((event) {
                    return _buildEventCard(event);
                  }).toList(),
                ),

              const SizedBox(height: 25),

              // ---------------------------------------------------------
              // SMALL CLEAN CALENDAR
              // ---------------------------------------------------------
              _buildSmallCalendar(),

              const SizedBox(height: 22),

              // ---------------------------------------------------------
              // SELECTED DATE
              // ---------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        color: softWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (selectedEvents.isEmpty)
                _buildSelectedDateEmpty()
              else
                Column(
                  children: selectedEvents.map((event) {
                    return _buildSelectedEventCard(event);
                  }).toList(),
                ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------
              // ADD EVENT
              // ---------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _showAddEventSheet,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'ADD EVENT',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // NO EVENTS
  // =====================================================================

  Widget _buildNoEvents() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_outlined, color: gold, size: 30),

          SizedBox(width: 13),

          Expanded(
            child: Text(
              'No events yet. Add an occasion and Vestra will remember it.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // EVENT CARD
  // =====================================================================

  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date']?.toString() ?? '');

    if (date == null) {
      return const SizedBox();
    }

    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          _focusedMonth = DateTime(date.year, date.month);
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF24200F) : card,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isSelected
                ? gold.withValues(alpha: 0.5)
                : gold.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    _monthName(date.month).substring(0, 3).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']?.toString() ?? 'Untitled Event',
                    style: const TextStyle(
                      color: softWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${event['occasion'] ?? 'Other'} • '
                    '${event['dressCode'] ?? 'No Dress Code'}',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),

                  if (event['time']?.toString().isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        event['time'].toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // SMALL CALENDAR
  // =====================================================================

  Widget _buildSmallCalendar() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);

    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDay.weekday - 1;

    final totalCells = startingWeekday + daysInMonth;

    final rows = (totalCells + 6) ~/ 7;

    return Column(
      children: [
        // Month selector
        Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _previousMonth,
              icon: const Icon(Icons.chevron_left, color: gold, size: 21),
            ),

            Expanded(
              child: Text(
                '${_monthName(_focusedMonth.month)} '
                '${_focusedMonth.year}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: softWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right, color: gold, size: 21),
            ),
          ],
        ),

        const SizedBox(height: 3),

        // Weekdays
        Row(
          children: List.generate(7, (index) {
            return Expanded(
              child: Center(
                child: Text(
                  _weekdayName(index + 1),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 5),

        // Days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rows * 7,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            if (index < startingWeekday ||
                index >= startingWeekday + daysInMonth) {
              return const SizedBox();
            }

            final day = index - startingWeekday + 1;

            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);

            final isSelected =
                date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;

            final isToday =
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day;

            final hasEvent = _hasEventOnDate(date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Center(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? gold : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: gold, width: 1)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isSelected ? Colors.black : softWhite,
                          fontSize: 10,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      if (hasEvent)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // =====================================================================
  // SELECTED DATE
  // =====================================================================

  Widget _buildSelectedDateEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.12)),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_outlined, color: Colors.white38, size: 23),

          SizedBox(width: 11),

          Text(
            'No event on this date.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedEventCard(Map<String, dynamic> event) {
    final location = event['location']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF24200F),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.event_outlined, color: gold, size: 22),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']?.toString() ?? 'Untitled Event',
                  style: const TextStyle(
                    color: softWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${event['occasion'] ?? 'Other'} • '
                  '${event['dressCode'] ?? 'No Dress Code'}',
                  style: const TextStyle(color: gold, fontSize: 10),
                ),

                if (event['time']?.toString().isNotEmpty ?? false)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      event['time'].toString(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),

                if (location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: () async {
              final eventIndex = EventsStore.events.indexOf(event);

              if (eventIndex == -1) {
                return;
              }

              await EventsStore.removeEvent(eventIndex);

              if (mounted) {
                setState(() {});
              }
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white38,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================================
// ADD EVENT SHEET
// =======================================================================

class _AddEventSheet extends StatefulWidget {
  final DateTime initialDate;

  const _AddEventSheet({required this.initialDate});

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  static const Color gold = Color(0xFFD4AF37);

  static const Color card = Color(0xFF151515);

  static const Color softWhite = Color(0xFFF5F1E8);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _locationController = TextEditingController();

  late DateTime _date;

  TimeOfDay? _time;

  String _occasion = 'Other';

  String _dressCode = 'Smart Casual';

  final List<String> _occasions = [
    'Wedding',
    'Graduation',
    'Birthday',
    'Date',
    'Work',
    'Party',
    'Dinner',
    'Travel',
    'Other',
  ];

  final List<String> _dressCodes = [
    'Black Tie',
    'Formal',
    'Business',
    'Smart Casual',
    'Casual',
    'Traditional',
    'No Dress Code',
  ];

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: gold,
              onPrimary: Colors.black,
              surface: card,
              onSurface: softWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _time = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final timeText = _time == null ? '' : _time!.format(context);

    await EventsStore.addEvent(
      title: _titleController.text,
      date: _date,
      time: timeText,
      occasion: _occasion,
      dressCode: _dressCode,
      location: _locationController.text,
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF101010),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: gold, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 25),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add an event',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: softWhite),
                decoration: _inputDecoration('Event name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an event name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              GestureDetector(
                onTap: _selectDate,
                child: _PickerField(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  value: '${_date.day}/${_date.month}/${_date.year}',
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _selectTime,
                child: _PickerField(
                  icon: Icons.access_time_outlined,
                  title: 'Time',
                  value: _time == null ? 'Add time' : _time!.format(context),
                ),
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _occasion,
                dropdownColor: card,
                style: const TextStyle(color: softWhite),
                decoration: _inputDecoration('Occasion'),
                items: _occasions.map((occasion) {
                  return DropdownMenuItem(
                    value: occasion,
                    child: Text(occasion),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _occasion = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _dressCode,
                dropdownColor: card,
                style: const TextStyle(color: softWhite),
                decoration: _inputDecoration('Dress code'),
                items: _dressCodes.map((dressCode) {
                  return DropdownMenuItem(
                    value: dressCode,
                    child: Text(dressCode),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _dressCode = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: softWhite),
                decoration: _inputDecoration('Location (optional)'),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'SAVE EVENT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// PICKER FIELD
// =======================================================================

class _PickerField extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _PickerField({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color gold = Color(0xFFD4AF37);

  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 21),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: softWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
