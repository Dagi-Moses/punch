import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeDropdown extends StatefulWidget {
 List<DateTime?>? availableDates;
  ValueChanged<DateTime?> onDateSelected;
DateTime? selectedDate;

   DateTimeDropdown({
    Key? key,
    required this.availableDates,
    required this.onDateSelected,
    this.selectedDate,
  }) : super(key: key);

  @override
  _DateTimeDropdownState createState() => _DateTimeDropdownState();
}

class _DateTimeDropdownState extends State<DateTimeDropdown> {
  

  @override
  Widget build(BuildContext context) {
    return DropdownButton<DateTime?>(
      value: widget.availableDates!.contains(widget.selectedDate) ? widget.selectedDate : null,
      hint: const Text("Select a Date"),
      items: widget.availableDates?.map((date) {
        return DropdownMenuItem<DateTime?>(
          value: date,
          child: Text(
            date != null
                ? DateFormat('yyyy-MM-dd').format(date)
                : 'Unknown Date',
          ),
        );
      }).toList(),
      onChanged: (DateTime? newDate) {
        setState(() {
          widget.selectedDate = newDate;
        });
        widget.onDateSelected(newDate);
      },
      isExpanded: true,
    );
  }
}
