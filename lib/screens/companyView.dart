import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';
import 'package:punch/models/myModels/companyWithExtra.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/companyProvider.dart';

class CompanyDetailView extends StatefulWidget {
  final CompanyWithExtra company;

  const CompanyDetailView({
    Key? key,
    required this.company,
  }) : super(key: key);

  @override
  State<CompanyDetailView> createState() => _CompanyDetailViewState();
}

class _CompanyDetailViewState extends State<CompanyDetailView> {
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

    nameController = TextEditingController(text: widget.company.company.name);
    dateController = TextEditingController(
      text: widget.company.company.date != null
          ? DateFormat('dd/MM/yyyy').format(widget.company.company.date!)
          : 'N/A',
    );
    addressController =
        TextEditingController(text: widget.company.company.address);
    emailController = TextEditingController(text: widget.company.company.email);
    phoneController = TextEditingController(text: widget.company.company.phone);
    faxController = TextEditingController(text: widget.company.company.fax);
    startDateController = TextEditingController(
      text: widget.company.company.startDate != null
          ? DateFormat('dd/MM/yyyy').format(widget.company.company.startDate!)
          : 'N/A',
    );
    managingDirectorController = TextEditingController(
        text: widget.company.companyExtra.managingDirector);
    corporateAffairsController = TextEditingController(
        text: widget.company.companyExtra.corporateAffairs);
    mediaManagerController =
        TextEditingController(text: widget.company.companyExtra.mediaManager);
    friendsController =
        TextEditingController(text: widget.company.companyExtra.friends);
    competitorsController =
        TextEditingController(text: widget.company.companyExtra.competitors);
    directorsController =
        TextEditingController(text: widget.company.companyExtra.directors);
    _companySectorTypeNotifier =
        ValueNotifier(widget.company.company.companySectorId);
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
                  selectedDate =
                      DateFormat('dd/MM/yyyy').parse(dateController.text);
                  DateTime? selectedStartDate;
                  selectedStartDate =
                      DateFormat('dd/MM/yyyy').parse(startDateController.text);

                  Company company = Company(
                    id: widget.company.company.id.toString(),
                    companyNo: widget.company.company.companyNo,
                    name: nameController.text,
                    address: addressController.text,
                    email: emailController.text,
                    fax: faxController.text,
                    phone: phoneController.text,
                    startDate: selectedStartDate,
                    date: selectedDate,
                    companySectorId: _companySectorTypeNotifier.value,
                  );

                  CompanyExtra companyExtra = CompanyExtra(
                    companyNo: widget.company.company.companyNo,
                    competitors: competitorsController.text,
                    corporateAffairs: corporateAffairsController.text,
                    directors: directorsController.text,
                    friends: friendsController.text,
                    id: widget.company.company.id,
                    managingDirector: managingDirectorController.text,
                    mediaManager: mediaManagerController.text,
                  );

                  try {
                    await companyProvider.updateCompany(company, companyExtra);
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
                          'Name: ${widget.company.company.name}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.vpn_key, size: 20),
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
                          'Fax: ${widget.company.company.fax}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.vpn_key, size: 20),
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
                          'Directors: ${widget.company.companyExtra.directors}',
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
                        const Icon(Icons.vpn_key, size: 20),
                        const SizedBox(width: 8.0),
                        Text(
                          'Company No: ${widget.company.company.companyNo}',
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
                            return DropdownButtonFormField<int>(
                              value: value,
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
                                  _companySectorTypeNotifier.value = newTypeId;
                                  widget.company.company.companySectorId =
                                      newTypeId;
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
                                        widget.company.company.companySectorId),
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
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: widget.company.companyExtra.friends,
                          decoration: InputDecoration(
                            labelText: 'Friends',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.companyExtra.friends = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Friends: ${widget.company.companyExtra.friends}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue:
                              widget.company.companyExtra.mediaManager,
                          decoration: InputDecoration(
                            labelText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.companyExtra.mediaManager = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Media Manager: ${widget.company.companyExtra.mediaManager}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue:
                              widget.company.companyExtra.corporateAffairs,
                          decoration: InputDecoration(
                            labelText: 'Corporate Affairs',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.companyExtra.corporateAffairs =
                                value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Corporate Affairs: ${widget.company.companyExtra.corporateAffairs}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: widget.company.company.address,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.company.address = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Address: ${widget.company.company.address}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
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
                                  widget.company.company.date ?? DateTime.now(),
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.company.company.date = selectedDate;
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
                        'Date: ${widget.company.company.date != null ? DateFormat('dd/MM/yyyy').format(widget.company.company.date!) : 'N/A'}',
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
                              initialDate: widget.company.company.startDate ??
                                  DateTime.now(),
                              firstDate: DateTime(1800),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.company.company.startDate = selectedDate;
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
                        'Start Date: ${widget.company.company.startDate != null ? DateFormat('dd/MM/yyyy').format(widget.company.company.startDate!) : 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.face, size: 20),
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
                        'Phone: ${widget.company.company.phone}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.face, size: 20),
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
                        'Email: ${widget.company.company.email}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue:
                              widget.company.companyExtra.managingDirector,
                          decoration: InputDecoration(
                            labelText: 'Managing Director',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.companyExtra.managingDirector =
                                value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Expanded(
                        child: Text(
                          'Managing Director: ${widget.company.companyExtra.managingDirector}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.badge, size: 20),
                const SizedBox(width: 8.0),
                isEditing
                    ? Expanded(
                        child: TextFormField(
                          initialValue: widget.company.companyExtra.competitors,
                          decoration: InputDecoration(
                            labelText: 'Competitors',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) {
                            widget.company.companyExtra.competitors = value;
                            // Save changes to the database
                          },
                        ),
                      )
                    : Text(
                        'Competitors: ${widget.company.companyExtra.competitors}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ],
            ),
          ])),
    );
  }
}
