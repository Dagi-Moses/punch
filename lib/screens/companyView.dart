import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';

import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/companyProvider.dart';

class CompanyDetailView extends StatefulWidget {
  Company company;

  CompanyDetailView({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
  CompanyExtra? companyExtra;
  late TextEditingController nameController;
  late TextEditingController dateController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController faxController;
  late TextEditingController startDateController;
  late TextEditingController managingDirectorController;
  late TextEditingController corporateAffairsController;
  late TextEditingController mediaManagerController;
  late TextEditingController friendsController;
  late TextEditingController competitorsController;
  late TextEditingController directorsController;
  late ValueNotifier<int?> _companySectorTypeNotifier;

  bool isEditing = false;
  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.company.name ?? "");
    dateController = TextEditingController(
      text: widget.company.date != null
          ? DateFormat('dd/MM/yyyy').format(widget.company.date!)
          : 'N/A',
    );
    addressController =
        TextEditingController(text: widget.company.address ?? "");
    emailController = TextEditingController(text: widget.company.email ?? "");
    phoneController = TextEditingController(text: widget.company.phone ?? "");
    faxController = TextEditingController(text: widget.company.fax ?? "");
    startDateController = TextEditingController(
      text: widget.company.startDate != null
          ? DateFormat('dd/MM/yyyy').format(widget.company.startDate!)
          : 'N/A',
    );
    managingDirectorController = TextEditingController();
    corporateAffairsController = TextEditingController();
    mediaManagerController = TextEditingController();
    friendsController = TextEditingController();
    competitorsController = TextEditingController();
    directorsController = TextEditingController();
    _companySectorTypeNotifier = ValueNotifier(widget.company.companySectorId);
    _fetchCompanyExtra();
  }

  Future<void> _fetchCompanyExtra() async {
    final clientExtraProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    companyExtra = await clientExtraProvider
        .getCompanyExtraByCompanyNo(widget.company.companyNo!);
    if (companyExtra != null) {
      setState(() {
        managingDirectorController.text = companyExtra?.managingDirector ?? "";
        corporateAffairsController.text = companyExtra?.corporateAffairs ?? "";
        mediaManagerController.text = companyExtra?.mediaManager ?? "";
        friendsController.text = companyExtra?.friends ?? "";
        competitorsController.text = companyExtra?.competitors ?? "";
        directorsController.text = companyExtra?.directors ?? "";
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    // companySectorIdController.dispose();
    dateController.dispose();
    addressController.dispose();
    emailController.dispose;
    phoneController.dispose();
    faxController.dispose();
    startDateController.dispose();
    managingDirectorController.dispose();
    corporateAffairsController.dispose();
    mediaManagerController.dispose();
    friendsController.dispose();
    competitorsController.dispose();
    directorsController.dispose();
    _companySectorTypeNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = Provider.of<CompanyProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        actions: [
          if (!isUser)
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  DateTime? selectedDate;
                  DateTime? selectedStartDate;

// Check if the dateController text is empty before parsing
                  try {
                    if (dateController.text.isNotEmpty) {
                      selectedDate =
                          DateFormat('dd/MM/yyyy').parse(dateController.text);
                    }
                  } catch (e) {
                    selectedDate = null;
                  }

                  try {
                    if (startDateController.text.isNotEmpty) {
                      selectedStartDate = DateFormat('dd/MM/yyyy')
                          .parse(startDateController.text);
                    }
                  } catch (e) {
                    selectedStartDate = null;
                  }

                  Company company = Company(
                    id: widget.company.id,
                    companyNo: widget.company.companyNo,
                    name: nameController.text,
                    address: addressController.text,
                    email: emailController.text,
                    fax: faxController.text,
                    phone: phoneController.text,
                    startDate: selectedStartDate,
                    date: selectedDate,
                    companySectorId: _companySectorTypeNotifier.value,
                  );

                  CompanyExtra _companyExtra = CompanyExtra(
                    companyNo: widget.company.companyNo,
                    competitors: competitorsController.text,
                    corporateAffairs: corporateAffairsController.text,
                    directors: directorsController.text,
                    friends: friendsController.text,
                    id: companyExtra?.id,
                    managingDirector: managingDirectorController.text,
                    mediaManager: mediaManagerController.text,
                  );

                  try {
                    
                    await companyProvider.updateCompany(company, _companyExtra,
                        () {
                      setState(() {
                        widget.company = company;
                        isEditing = false;
                      });
                    }, context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Company updated successfully!')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update Company')),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Consumer<CompanyProvider>(
        builder: (context, companyProvider, child) {
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
                  const Icon(Icons.account_circle, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Name: ${widget.company.name}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.print, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: faxController,
                            // decoration: const InputDecoration(labelText: 'Name'),
                            //  initialValue:
                            //   widget.anniversary.name,
                            decoration: InputDecoration(
                              labelText: 'Fax',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Fax: ${widget.company.fax}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              isEditing ? SizedBox() : const SizedBox(height: 8.0),
              isEditing
                  ? SizedBox()
                  : Row(
                      children: [
                        const Icon(Icons.key, size: 20),
                        const SizedBox(width: 8.0),
                        Text(
                          'Company No: ${widget.company.companyNo}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: ValueListenableBuilder<int?>(
                            valueListenable: _companySectorTypeNotifier,
                            builder: (context, value, child) {
                              // Ensure value is valid or set to null if not in the list
                              final validValue = companyProvider
                                      .companySectors.keys
                                      .contains(value)
                                  ? value
                                  : null;

                              return DropdownButtonFormField<int>(
                                value: validValue,
                                decoration: InputDecoration(
                                  labelText: 'Company Sector',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                items: companyProvider.companySectors.keys
                                    .map((int typeId) {
                                  return DropdownMenuItem<int>(
                                    value: typeId,
                                    child: Text(companyProvider
                                        .getCompanySectorDescription(typeId)),
                                  );
                                }).toList(),
                                onChanged: (int? newTypeId) {
                                  if (newTypeId != null) {
                                    _companySectorTypeNotifier.value =
                                        newTypeId;
                                    widget.company.companySectorId = newTypeId;
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
                                text: 'Company Sector: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .amber, // Amber color for the 'UserRole:' text
                                ),
                              ),
                              TextSpan(
                                text:
                                    companyProvider.getCompanySectorDescription(
                                        widget.company.companySectorId),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors
                                      .black, // Black color for the role value
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
                                  widget.company.date ?? DateTime.now(),
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.company.date = selectedDate;
                                dateController.text = DateFormat('dd/MM/yyyy')
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
                              controller: dateController,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Date: ${widget.company.date != null ? DateFormat('dd/MM/yyyy').format(widget.company.date!) : 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                                  widget.company.startDate ?? DateTime.now(),
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.company.startDate = selectedDate;
                                startDateController.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate);
                              });
                              // Save changes to the database
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Start date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: startDateController,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Start Date: ${widget.company.startDate != null ? DateFormat('dd/MM/yyyy').format(widget.company.startDate!) : 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          //   decoration: const InputDecoration(labelText: 'Address'),
                          decoration: InputDecoration(
                            labelText: 'Phone ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Phone: ${widget.company.phone}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.email, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Email: ${widget.company.email}',
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
                          initialValue: widget.company.address,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.address = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Address: ${widget.company.address}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
          ])),
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
              'Extras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.business_center, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: managingDirectorController.text,
                          decoration: InputDecoration(
                            labelText: 'Managing Director',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            companyExtra?.managingDirector = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Expanded(
                        child: Text(
                          'Managing Director: ${managingDirectorController.text}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.business_center, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: corporateAffairsController.text,
                          decoration: InputDecoration(
                            labelText: 'Corporate Affairs',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            companyExtra?.corporateAffairs = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Corporate Affairs: ${corporateAffairsController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.folder, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: mediaManagerController.text,
                          decoration: InputDecoration(
                            labelText: 'Media Manager',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            companyExtra?.mediaManager = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Media Manager: ${mediaManagerController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.favorite, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: friendsController.text,
                          decoration: InputDecoration(
                            labelText: 'Friends',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            companyExtra?.friends = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Friends: ${friendsController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.sports_soccer, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: competitorsController.text,
                          decoration: InputDecoration(
                            labelText: 'Competitors',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            companyExtra?.competitors = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Competitors: ${competitorsController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          controller: directorsController,
                          decoration: InputDecoration(
                            labelText: 'Directors',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Directors: ${directorsController.text}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
