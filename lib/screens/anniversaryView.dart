import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';

class AnniversaryDetailView extends StatefulWidget {
  final Anniversary anniversary;

  const AnniversaryDetailView({
    Key? key,
    required this.anniversary,
  }) : super(key: key);

  @override
  State<AnniversaryDetailView> createState() => _AnniversaryDetailViewState();
}

class _AnniversaryDetailViewState extends State<AnniversaryDetailView> {
  bool isEditing = false;

  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController placedByNameController;
  late TextEditingController placedByAddressController;
  late TextEditingController placedByPhoneController;
  late TextEditingController friendsController;
  late TextEditingController associatesController;
  late TextEditingController anniversaryYearController;
  late TextEditingController paperIdController;
  late ValueNotifier<AnniversaryType> _anniversaryTypeNotifier;
  late TextEditingController _dateController;
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.anniversary.name);
    placedByNameController =
        TextEditingController(text: widget.anniversary.placedByName);
    placedByAddressController =
        TextEditingController(text: widget.anniversary.placedByAddress);
    placedByPhoneController =
        TextEditingController(text: widget.anniversary.placedByPhone);
    friendsController =
        TextEditingController(text: widget.anniversary.friends ?? '');
    associatesController =
        TextEditingController(text: widget.anniversary.associates ?? '');
    anniversaryYearController = TextEditingController(
        text: widget.anniversary.anniversaryYear.toString());
    paperIdController =
        TextEditingController(text: widget.anniversary.paperId.toString());

    _anniversaryTypeNotifier =
        ValueNotifier(widget.anniversary.anniversaryTypeId);
    _dateController = TextEditingController(
      text: widget.anniversary.date != null
          ? DateFormat('dd/MM/yyyy').format(widget.anniversary.date!)
          : 'N/A',
    );
  }

  @override
  void dispose() {
    // Dispose controllers when not needed
    nameController.dispose();
    placedByNameController.dispose();
    placedByAddressController.dispose();
    placedByPhoneController.dispose();
    friendsController.dispose();
    associatesController.dispose();
    anniversaryYearController.dispose();
    paperIdController.dispose();
    _anniversaryTypeNotifier.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anniversary Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                DateTime? selectedDate;

                selectedDate =
                    DateFormat('dd/MM/yyyy').parse(_dateController.text);
                Anniversary anni = Anniversary(
                  id: widget.anniversary.id,
                  anniversaryNo: int.tryParse(widget.anniversary.id!),
                  name: nameController.text,
                  placedByName: placedByNameController.text,
                  placedByAddress: placedByAddressController.text,
                  placedByPhone: placedByPhoneController.text,
                  friends: friendsController.text,
                  associates: associatesController.text,
                  anniversaryYear: int.tryParse(anniversaryYearController.text),
                  paperId: int.tryParse(paperIdController.text),
                  date:
                      selectedDate, // You might want to handle date change separately
                  anniversaryTypeId: _anniversaryTypeNotifier.value,
                );
                try {
                  await anniversaryProvider.updateAnniversary(anni);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Anniversary updated successfully!')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to update anniversary')),
                  );
                }
              }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16.0),
            _buildDetailSection(),
            const SizedBox(height: 16.0),
            _buildContactSection(),
            const SizedBox(height: 16.0),
            _buildPeopleSection('Friends', friendsController),
            const SizedBox(height: 16.0),
            _buildPeopleSection('Associates', associatesController),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isEditing
                ? TextFormField(
                    controller: nameController,
                    // decoration: const InputDecoration(labelText: 'Name'),
                    //  initialValue:
                    //   widget.anniversary.name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(
                    widget.anniversary.name!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? ValueListenableBuilder<AnniversaryType>(
                    valueListenable: _anniversaryTypeNotifier,
                    builder: (context, value, child) {
                      return DropdownButtonFormField<AnniversaryType>(
                        value: value,
                        decoration: InputDecoration(
                          labelText: 'Event Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items:
                            AnniversaryType.values.map((AnniversaryType type) {
                          return DropdownMenuItem<AnniversaryType>(
                            value: type,
                            child: Text(type.description),
                          );
                        }).toList(),
                        onChanged: (AnniversaryType? newType) {
                          if (newType != null) {
                            _anniversaryTypeNotifier.value = newType;
                            widget.anniversary.anniversaryTypeId = newType;
                            // Save changes to the database (implement this logic)
                          }
                        },
                      );
                    },
                  )
                : Text(
                    getAnniversaryEvent(widget.anniversary.anniversaryTypeId),
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.amber,
                    ),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: widget.anniversary.date ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          widget.anniversary.date = selectedDate;
                          _dateController.text =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                        // Save changes to the database
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: _dateController,
                      ),
                    ),
                  )
                : Text(
                    'Date: ${widget.anniversary.date != null ? DateFormat('dd/MM/yyyy').format(widget.anniversary.date!) : 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextFormField(
                    initialValue:
                        widget.anniversary.anniversaryYear?.toString(),
                    decoration: InputDecoration(
                      labelText: 'Anniversary Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      widget.anniversary.anniversaryYear = int.tryParse(value);
                      // Save changes to the database
                    },
                  )
                : Text(
                    'Anniversary Year: ${widget.anniversary.anniversaryYear}',
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextFormField(
                    controller: placedByNameController,
                    //   decoration: const InputDecoration(labelText: 'Placed By'),
                    decoration: InputDecoration(
                      labelText: 'Placed By',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(
                    'Placed By: ${widget.anniversary.placedByName}',
                    style: const TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextFormField(
                    controller: placedByAddressController,
                    //   decoration: const InputDecoration(labelText: 'Address'),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(
                    'Address: ${widget.anniversary.placedByAddress}',
                    style: const TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextField(
                    controller: placedByPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(
                    'Phone: ${widget.anniversary.placedByPhone}',
                    style: const TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextField(
                    controller: paperIdController,
                    decoration: InputDecoration(
                      labelText: 'Paper ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Text(
                    'Paper ID: ${widget.anniversary.paperId}',
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.phone, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextField(
                          controller: placedByPhoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.anniversary.placedByPhone!,
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextField(
                          controller: placedByAddressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Text(
                          widget.anniversary.placedByAddress!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleSection(String title, TextEditingController controller) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            isEditing
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: title,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      controller.text.isNotEmpty ? controller.text : "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
