import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnniversaryViewPage extends StatefulWidget {
  final Anniversary anniversary;

  AnniversaryViewPage({required this.anniversary});

  @override
  _AnniversaryViewPageState createState() => _AnniversaryViewPageState();
}

class _AnniversaryViewPageState extends State<AnniversaryViewPage> {
  late TextEditingController _nameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.anniversary.name);
    _selectedDate = widget.anniversary.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1880),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveChanges() {
    // Save logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Anniversary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _selectDate,
                  child: Text('Change Date'),
                ),
              ],
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Save'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Anniversary {
  final String name;
  final DateTime date;

  Anniversary({required this.name, required this.date});
}
