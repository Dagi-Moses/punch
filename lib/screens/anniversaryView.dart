import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';

import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';

class AnniversaryDetailView extends StatefulWidget {
  Anniversary anniversary;

  AnniversaryDetailView({
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

  late ValueNotifier<int?> _anniversaryTypeNotifier;

  late ValueNotifier<int?> _paperIdNotifier;
  late TextEditingController _dateController;
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.anniversary.name ?? "");
    placedByNameController =
        TextEditingController(text: widget.anniversary.placedByName ?? "");
    placedByAddressController =
        TextEditingController(text: widget.anniversary.placedByAddress ?? "");
    placedByPhoneController =
        TextEditingController(text: widget.anniversary.placedByPhone ?? "");
    friendsController =
        TextEditingController(text: widget.anniversary.friends ?? '');
    associatesController =
        TextEditingController(text: widget.anniversary.associates ?? '');
    anniversaryYearController = TextEditingController(
        text: widget.anniversary.anniversaryYear.toString() ?? "");

    _anniversaryTypeNotifier =
        ValueNotifier(widget.anniversary.anniversaryTypeId);
    _paperIdNotifier = ValueNotifier(widget.anniversary.paperId);
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

    _anniversaryTypeNotifier.dispose();
    _paperIdNotifier.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
     final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anniversary Details'),
       actions: [
        if (!isUser)   IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                DateTime? selectedDate;

                try {
                  selectedDate =
                      DateFormat('dd/MM/yyyy').parse(_dateController.text);
                } catch (e) {
                  // Handle parsing error
                  print("Error parsing date: $e");
                }

                Anniversary updatedAnniversary = Anniversary(
                  id: widget.anniversary.id,
                  anniversaryNo: widget.anniversary.anniversaryNo,
                  name: nameController.text,
                  placedByName: placedByNameController.text,
                  placedByAddress: placedByAddressController.text,
                  placedByPhone: placedByPhoneController.text,
                  friends: friendsController.text,
                  associates: associatesController.text,
                  anniversaryYear: int.tryParse(anniversaryYearController.text),
                  paperId: _paperIdNotifier.value,
                  date: selectedDate,
                  anniversaryTypeId: _anniversaryTypeNotifier.value,
                );

                try {
                  await anniversaryProvider
                      .updateAnniversary(updatedAnniversary);
                  setState(() {
                    // Replace the entire anniversary object with the updated one
                    widget.anniversary = updatedAnniversary;
                    isEditing = false;
                  });
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
              } else {
                setState(() {
                  isEditing = true;
                });
              }
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Consumer<AnniversaryProvider>(
        builder: (context, anniversaryProvider, child) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
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
                          ),
                        )
                      : Text(
                          'Name: ${widget.anniversary.name}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
           Row(
  children: [
    const Icon(Icons.card_giftcard, size: 20),
    const SizedBox(width: 8.0),
    isEditing
        ? Expanded(
            child: ValueListenableBuilder<int?>(
              valueListenable: _anniversaryTypeNotifier,
              builder: (context, value, child) {
                // If the current value is null or not in the list, set it to a default or null value
                if (value == null || 
                    !anniversaryProvider.anniversaryTypes.keys.contains(value)) {
                  value = null; // or set to a default value that exists in your list
                }

                return DropdownButtonFormField<int>(
                  value: value,
                  decoration: InputDecoration(
                    labelText: 'Anniversary Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: anniversaryProvider.anniversaryTypes.keys
                      .map((int typeId) {
                    return DropdownMenuItem<int>(
                      value: typeId,
                      child: Text(
                        anniversaryProvider.getAnniversaryTypeDescription(typeId),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newTypeId) {
                    if (newTypeId != null) {
                      _anniversaryTypeNotifier.value = newTypeId;
                      widget.anniversary.anniversaryTypeId = newTypeId;
                      // Save changes to the database (implement this logic)
                    }
                  },
                );
              },
            ),
          )
        
                      : RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Anniversary Type: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .black, // Amber color for the 'UserRole:' text
                                ),
                              ),
                              TextSpan(
                                text: anniversaryProvider
                                    .getAnniversaryTypeDescription(
                                        widget.anniversary.anniversaryTypeId),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .amber, // Black color for the role value
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    widget.anniversary.date ?? DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  widget.anniversary.date = selectedDate;
                                  _dateController.text =
                                      DateFormat('dd/MM/yyyy')
                                          .format(selectedDate);
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
                          ),
                        )
                      : Text(
                          'Date: ${widget.anniversary.date != null ? DateFormat('dd/MM/yyyy').format(widget.anniversary.date!) : 'N/A'}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.timeline, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
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
                              widget.anniversary.anniversaryYear =
                                  int.tryParse(value);
                              // Save changes to the database
                            },
                          ),
                        )
                      : Text(
                          'Anniversary Year: ${widget.anniversary.anniversaryYear}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailSection() {
    return Consumer<AnniversaryProvider>(
        builder: (context, anniversaryProvider, child) {
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
              Row(
                children: [
                  const Icon(Icons.group, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: placedByNameController,
                            //   decoration: const InputDecoration(labelText: 'Placed By'),
                            decoration: InputDecoration(
                              labelText: 'Placed By',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Placed By: ${widget.anniversary.placedByName}',
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
                          child: TextFormField(
                            controller: placedByAddressController,
                            //   decoration: const InputDecoration(labelText: 'Address'),
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Address: ${widget.anniversary.placedByAddress}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
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
                          'Phone: ${widget.anniversary.placedByPhone}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.phone, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextField(
                            controller: friendsController,
                            decoration: InputDecoration(
                              labelText: 'Friends',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Friends: ${widget.anniversary.friends}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.phone, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextField(
                            controller: associatesController,
                            decoration: InputDecoration(
                              labelText: 'Associates',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Associates: ${widget.anniversary.associates}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.card_giftcard, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: ValueListenableBuilder<int?>(
                          valueListenable: _paperIdNotifier,
                          builder: (context, value, child) {
                            return DropdownButtonFormField<int>(
                              value: value,
                              decoration: InputDecoration(
                                labelText: 'Paper',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: anniversaryProvider.paperTypes.keys
                                  .map((int typeId) {
                                return DropdownMenuItem<int>(
                                  value: typeId,
                                  child: Text(anniversaryProvider
                                      .getPaperTypeDescription(typeId)),
                                );
                              }).toList(),
                              onChanged: (int? newTypeId) {
                                if (newTypeId != null) {
                                  _paperIdNotifier.value = newTypeId;
                                  widget.anniversary.paperId = newTypeId;
                                  // Save changes to the database (implement this logic)
                                }
                              },
                            );
                          },
                        ))
                      : RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Paper: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .black, // Amber color for the 'UserRole:' text
                                ),
                              ),
                              TextSpan(
                                text:
                                    anniversaryProvider.getPaperTypeDescription(
                                        widget.anniversary.paperId),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .amber, // Black color for the role value
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
