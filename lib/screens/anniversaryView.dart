import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';

import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/utils/html%20handler.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';

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

  late HtmlTextHandler placedByHandler;
  late HtmlTextHandler associatesHandler;
  late HtmlTextHandler friendsHandler;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.anniversary.name ?? "");
    placedByNameController = TextEditingController(
        text: _convertHtmlToText(widget.anniversary.placedByName ?? ""));
    placedByAddressController =
        TextEditingController(text: widget.anniversary.placedByAddress ?? "");
    placedByPhoneController =
        TextEditingController(text: widget.anniversary.placedByPhone ?? "");
    friendsController = TextEditingController(
        text: _convertHtmlToText(widget.anniversary.friends ?? ""));
    associatesController = TextEditingController(
        text: _convertHtmlToText(widget.anniversary.associates ?? ""));
    anniversaryYearController = TextEditingController(
        text: widget.anniversary.anniversaryYear.toString());

    _anniversaryTypeNotifier =
        ValueNotifier(widget.anniversary.anniversaryTypeId);
    _paperIdNotifier = ValueNotifier(widget.anniversary.paperId);
    _dateController = TextEditingController(
      text: widget.anniversary.date != null
          ? DateFormat('dd/MM/yyyy').format(widget.anniversary.date!)
          : 'N/A',
    );

    associatesHandler = HtmlTextHandler(
      controller: associatesController,
      onTextChanged: (text) {
        setState(() {
          widget.anniversary.associates = text;
        });
      },
      initialText: associatesController.text,
    );

    placedByHandler = HtmlTextHandler(
      controller: placedByNameController,
      onTextChanged: (text) {
        setState(() {
          widget.anniversary.placedByName = text;
        });
      },
      initialText: placedByNameController.text,
    );

    friendsHandler = HtmlTextHandler(
      controller: friendsController,
      onTextChanged: (text) {
        setState(() {
          widget.anniversary.friends = text;
        });
      },
      initialText: friendsController.text,
    );
  }

  String _convertHtmlToText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
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
          if (!isUser)
            IconButton(
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
                    placedByName: placedByNameController.text.replaceAll('\n', '<br>'),
                    placedByAddress: placedByAddressController.text,
                    placedByPhone: placedByPhoneController.text,
                    friends: friendsController.text.replaceAll('\n', '<br>'),
                    associates: associatesController.text.replaceAll('\n', '<br>'),
                    anniversaryYear:
                        int.tryParse(anniversaryYearController.text),
                    paperId: _paperIdNotifier.value,
                    date: selectedDate,
                    anniversaryTypeId: _anniversaryTypeNotifier.value,
                  );

                  await anniversaryProvider.updateAnniversary(
                      updatedAnniversary, context);
                  setState(() {
                    // Replace the entire anniversary object with the updated one
                    widget.anniversary = updatedAnniversary;
                    isEditing = false;
                  });
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
              FormFieldWidget(
                controller: nameController,
                label: 'Name',
                htmlData: widget.anniversary.name,
                isEditing: isEditing,
                icon: Icons.person,
              ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Row(
                      children: [
                        const Icon(Icons.card_giftcard, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ValueListenableBuilder<int?>(
                            valueListenable: _anniversaryTypeNotifier,
                            builder: (context, value, child) {
                              // If the current value is null or not in the list, set it to a default or null value
                              if (value == null ||
                                  !anniversaryProvider.anniversaryTypes.keys
                                      .contains(value)) {
                                value =
                                    null; // or set to a default value that exists in your list
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
                                      anniversaryProvider
                                          .getAnniversaryTypeDescription(
                                              typeId),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newTypeId) {
                                  if (newTypeId != null) {
                                    _anniversaryTypeNotifier.value = newTypeId;
                                    widget.anniversary.anniversaryTypeId =
                                        newTypeId;
                                    // Save changes to the database (implement this logic)
                                  }
                                },
                              );
                            },
                          ),
                        )
                      ],
                    )
                  : TextFieldWidget(
                      label: "Anniversary Type",
                      htmlData:
                          anniversaryProvider.getAnniversaryTypeDescription(
                              widget.anniversary.anniversaryTypeId),
                      icon: Icons.card_giftcard,
                    ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
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
                      ],
                    )
                  : TextFieldWidget(
                      label: 'Date',
                      htmlData: widget.anniversary.date != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(widget.anniversary.date!)
                          : 'N/A',
                      icon: Icons.calendar_today,
                    ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Row(
                      children: [
                        const Icon(Icons.timeline, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
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
                      ],
                    )
                  : TextFieldWidget(
                      label: 'Anniversary Year',
                      htmlData: widget.anniversary.anniversaryYear.toString(),
                      icon: Icons.timeline,
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
              FormFieldWidget(
                controller: placedByNameController,
                label: 'Placed by Name',
                htmlData: widget.anniversary.placedByName,
                isEditing: isEditing,
                icon: Icons.group,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: placedByAddressController,
                label: 'Placed by Address',
                htmlData: widget.anniversary.placedByAddress,
                isEditing: isEditing,
                icon: Icons.location_on,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: placedByPhoneController,
                label: 'Placed by Phone',
                htmlData: widget.anniversary.placedByPhone,
                isEditing: isEditing,
                icon: Icons.phone,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: friendsController,
                label: 'Friends',
                htmlData: widget.anniversary.friends,
                isEditing: isEditing,
                icon: Icons.favorite,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: associatesController,
                label: 'Associates',
                htmlData: widget.anniversary.associates,
                isEditing: isEditing,
                icon: Icons.people,
              ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Row(
                      children: [
                        const Icon(Icons.card_giftcard, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
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
                      ],
                    )
                  : TextFieldWidget(
                      label: 'Paper',
                      htmlData: anniversaryProvider
                          .getPaperTypeDescription(widget.anniversary.paperId),
                      icon: Icons.card_giftcard,
                    ),
            ],
          ),
        ),
      );
    });
  }
}
