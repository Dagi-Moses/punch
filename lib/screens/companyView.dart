import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:punch/models/myModels/companyExtraModel.dart';
import 'package:punch/models/myModels/companyModel.dart';

import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/providers/companyProvider.dart';
import 'package:punch/utils/html%20handler.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';

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


  late HtmlTextHandler managingDirectorHandler;
  late HtmlTextHandler corporateAffairsHandler;
  late HtmlTextHandler mediaManagerHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler competitorsHandler;
  late HtmlTextHandler directorsHandler;
 

  bool isEditing = false;
  @override
  void initState() {
    super.initState();
initialize();
 
  }
  void initialize()async{
    nameController = TextEditingController(
        text: _convertHtmlToText(widget.company.name ?? ""));
    dateController = TextEditingController(
      text: widget.company.date != null
          ? DateFormat('dd/MM/yyyy').format(widget.company.date!)
          : 'N/A',
    );
    addressController = TextEditingController(
        text: _convertHtmlToText(widget.company.address ?? ""));
    emailController = TextEditingController(
        text: _convertHtmlToText(widget.company.email ?? ""));
    phoneController = TextEditingController(
        text: _convertHtmlToText(widget.company.phone ?? ""));
    faxController = TextEditingController(
        text: _convertHtmlToText(widget.company.fax ?? ""));
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
   await  _fetchCompanyExtra();
    managingDirectorHandler = HtmlTextHandler(
        controller: managingDirectorController,
        onTextChanged: (text) {
          setState(() {
            companyExtra?.managingDirector = text;
          });
        },
        initialText: managingDirectorController.text);
   
    corporateAffairsHandler = HtmlTextHandler(
        controller: corporateAffairsController,
        onTextChanged: (text) {
          setState(() {
            companyExtra?.corporateAffairs = text;
          });
        },
        initialText: corporateAffairsController.text);

    mediaManagerHandler = HtmlTextHandler(
        controller: mediaManagerController,
        onTextChanged: (text) {
          setState(() {
            companyExtra?.mediaManager = text;
          });
        },
        initialText: mediaManagerController.text);
    directorsHandler = HtmlTextHandler(
        controller: directorsController,
        onTextChanged: (text) {
          setState(() {
            companyExtra?.directors = text;
          });
        },
        initialText: directorsController.text);
    competitorsHandler = HtmlTextHandler(
        controller: competitorsController,
        onTextChanged: (text) {
          setState(() {
            companyExtra?.competitors = text;
          });
        },
        initialText: competitorsController.text);
    friendsHandler = HtmlTextHandler(
        controller: friendsController,
        onTextChanged: (text) {
          setState(() {
          companyExtra?.friends = text;
          });
        },
        initialText: friendsController.text);
  }

  Future<void> _fetchCompanyExtra() async {
    final clientExtraProvider =
        Provider.of<CompanyProvider>(context, listen: false);
    companyExtra = await clientExtraProvider
        .getCompanyExtraByCompanyNo(widget.company.companyNo!);
    if (companyExtra != null) {
      setState(() {
        managingDirectorController.text =   _convertHtmlToText(companyExtra?.managingDirector ?? "");
        corporateAffairsController.text = _convertHtmlToText(companyExtra?.corporateAffairs ?? "");
        mediaManagerController.text =  _convertHtmlToText(companyExtra?.mediaManager ?? "");
        friendsController.text =  _convertHtmlToText(companyExtra?.friends ?? "");
        competitorsController.text =
            _convertHtmlToText(companyExtra?.competitors ?? "");
        directorsController.text =  _convertHtmlToText(companyExtra?.directors ?? "");
      });
    }
  }
  
  String _convertHtmlToText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
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
                    competitors: competitorsController.text.replaceAll('\n', '<br>'),
                    corporateAffairs: corporateAffairsController.text
                        .replaceAll('\n', '<br>'),
                    directors: directorsController.text.replaceAll('\n', '<br>'),
                    friends: friendsController.text.replaceAll('\n', '<br>'),
                    id: companyExtra?.id,
                    managingDirector: managingDirectorController.text
                        .replaceAll('\n', '<br>'),
                    mediaManager: mediaManagerController.text.replaceAll('\n', '<br>'),
                  );

                  await companyProvider.updateCompany(company, _companyExtra,
                      () {
                    setState(() {
                      widget.company = company;
                      companyExtra = _companyExtra;
                      isEditing = false;
                    });
                  }, context);
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
                FormFieldWidget(
                controller: nameController,
                label: 'Name',
                htmlData: widget.company.name,
                isEditing: isEditing,
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 8.0),
               FormFieldWidget(
                controller: faxController,
                label: 'Fax',
                htmlData: widget.company.fax,
                isEditing: isEditing,
                icon: Icons.print,
              ),
              isEditing ? const SizedBox() : const SizedBox(height: 8.0),
             isEditing
                  ? const SizedBox():    TextFieldWidget(
                label: 'Company Number',
                htmlData: widget.company.companyNo.toString(),
                icon: Icons.key,
              ),
              const SizedBox(height: 8.0),
           isEditing
                      ?     Row(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 20),
                  const SizedBox(width: 8.0),
                 Expanded(
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
                ],
              ):TextFieldWidget(
                label: 'Company Sector',
                htmlData: companyProvider
                                      .getCompanySectorDescription(
                                          widget.company.companySectorId),
                icon: Icons.admin_panel_settings,
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
         isEditing
                    ?    Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
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
              ],
            ): TextFieldWidget(
                label: 'Date',
                htmlData: widget.company.date != null ? DateFormat('dd/MM/yyyy').format(widget.company.date!) : 'N/A',
                icon: Icons.calendar_today,
              ),
            const SizedBox(height: 8.0),
              isEditing
                    ?   Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8.0),
            Expanded(
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
              ],
            )
            : TextFieldWidget(
                label: 'Start Date',
                htmlData: widget.company.startDate != null ? DateFormat('dd/MM/yyyy').format(widget.company.startDate!) : 'N/A',
                icon: Icons.calendar_today,
              ),
            const SizedBox(height: 8.0),
             FormFieldWidget(
              isEditing: isEditing,
              controller: phoneController,
              label: 'Phone',
              htmlData: widget.company.phone,
              icon: Icons.phone,
            ),
            const SizedBox(height: 8.0),
              FormFieldWidget(
              isEditing: isEditing,
              controller: emailController,
              label: 'Email',
              htmlData: widget.company.email,
              icon: Icons.email,
            ),
            const SizedBox(height: 8.0),
              FormFieldWidget(
              isEditing: isEditing,
              controller: addressController,
              label: 'Address',
              htmlData: widget.company.address,
              icon: Icons.location_on,
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
             FormFieldWidget(
              isEditing: isEditing,
              controller: managingDirectorController,
              label: 'Managing Director',
              htmlData: companyExtra?.managingDirector,
              icon: Icons.business_center,
            ),
            const SizedBox(height: 8.0),
             FormFieldWidget(
              isEditing: isEditing,
              controller: corporateAffairsController,
              label: 'Corporate Affairs', 
              htmlData: companyExtra?.corporateAffairs,
              icon: Icons.business,
            ),
            const SizedBox(height: 8.0),
                FormFieldWidget(
              isEditing: isEditing,
              controller: mediaManagerController,
              label: 'Media Manager',
              htmlData: companyExtra?.mediaManager,
              icon: Icons.folder,
            ),
            const SizedBox(height: 8.0),
             FormFieldWidget(
              isEditing: isEditing,
              controller: friendsController,
              label: 'Friends',
              htmlData: companyExtra?.friends,
              icon: Icons.favorite,
            ),
            const SizedBox(height: 8.0),
              FormFieldWidget(
              isEditing: isEditing,
              controller:  competitorsController,
              label:  'Competitors',
              htmlData: companyExtra?.competitors,
              icon: Icons.sports_soccer,
            ),
            const SizedBox(height: 8.0),
             FormFieldWidget(
              isEditing: isEditing,
              controller: directorsController,
              label: 'Directors',
              htmlData: companyExtra?.directors,
              icon: Icons.meeting_room,
            ),
          ],
        ),
      ),
    );
  }
}
