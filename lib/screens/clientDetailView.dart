import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/providers/clientProvider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:punch/utils/html%20handler.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';

class ClientDetailView extends StatefulWidget {
  Client client;

  ClientDetailView({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  State<ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends State<ClientDetailView> {
  bool isEditing = false;

  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController dateOfBirthController;
  late TextEditingController telephoneController;
  late TextEditingController emailController;
  late TextEditingController placeOfWorkController;
  late TextEditingController associatesController;
  late TextEditingController friendsController;
  late TextEditingController politicalPartyController;
  late TextEditingController presentPositionController;
  late TextEditingController hobbiesController;
  late TextEditingController companiesController;
  late ValueNotifier<int?> _titleIdNotifier;
  ClientExtra? clientExtra;

  late HtmlTextHandler placeOfWorkHandler;
  late HtmlTextHandler associatesHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler presentPositionHandler;
  late HtmlTextHandler politicalPartyHandler;
  late HtmlTextHandler hobbiesHandler;
  late HtmlTextHandler companiesHandler;
  @override
  void initState() {
    super.initState();
  Initialize();
  }

 void Initialize() async {
    // Initialize controllers with converted text
    lastNameController = TextEditingController(
        text: _convertHtmlToText(widget.client.lastName ?? ""));
    firstNameController = TextEditingController(
        text: _convertHtmlToText(widget.client.firstName ?? ""));
    middleNameController = TextEditingController(
        text: _convertHtmlToText(widget.client.middleName ?? ""));
    telephoneController = TextEditingController(
        text: _convertHtmlToText(widget.client.telephone ?? ""));
    emailController = TextEditingController(
        text: _convertHtmlToText(widget.client.email ?? ''));
    placeOfWorkController = TextEditingController(
        text: _convertHtmlToText(widget.client.placeOfWork ?? ""));
    associatesController = TextEditingController(
        text: _convertHtmlToText(widget.client.associates ?? ""));
    friendsController = TextEditingController(
        text: _convertHtmlToText(widget.client.friends ?? ""));
    politicalPartyController = TextEditingController();
    presentPositionController = TextEditingController();
    hobbiesController = TextEditingController();
    companiesController = TextEditingController();
    dateOfBirthController = TextEditingController(
      text: widget.client.dateOfBirth != null
          ? DateFormat('dd/MM/yyyy').format(widget.client.dateOfBirth!)
          : null,
    );
    _titleIdNotifier = ValueNotifier(widget.client.titleId);

    // Fetch clientExtra and populate the fields
     await
      _fetchClientExtra();
    
  


    companiesHandler = HtmlTextHandler(
      controller: companiesController,
      onTextChanged: (text) {
        setState(() {
          clientExtra?.companies = text;
        });
      },
      initialText: companiesController.text,
    );

    hobbiesHandler = HtmlTextHandler(
      controller: hobbiesController,
      onTextChanged: (text) {
        setState(() {
          clientExtra?.hobbies = text;
        });
      },
      initialText: hobbiesController.text,
    );

    politicalPartyHandler = HtmlTextHandler(
      controller: politicalPartyController,
      onTextChanged: (text) {
        setState(() {
          clientExtra?.politicalParty = text;
        });
      },
      initialText: politicalPartyController.text,
    );

    presentPositionHandler = HtmlTextHandler(
      controller: presentPositionController,
      onTextChanged: (text) {
        setState(() {
          clientExtra?.presentPosition = text;
        });
      },
      initialText: presentPositionController.text,
    );

    placeOfWorkHandler = HtmlTextHandler(
      controller: placeOfWorkController,
      onTextChanged: (text) {
        setState(() {
          widget.client.placeOfWork = text;
        });
      },
      initialText: placeOfWorkController.text,
    );

    associatesHandler = HtmlTextHandler(
      controller: associatesController,
      onTextChanged: (text) {
        setState(() {
          widget.client.associates = text;
        });
      },
      initialText: associatesController.text,
    );

    friendsHandler = HtmlTextHandler(
        controller: friendsController,
        onTextChanged: (text) {
          setState(() {
            widget.client.friends = text;
          });
        },
        initialText: friendsController.text);
  }

  String _convertHtmlToText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }
  Future<void> _fetchClientExtra() async {
    final clientExtraProvider =
        Provider.of<ClientExtraProvider>(context, listen: false);
    clientExtra = await clientExtraProvider
        .getClientExtraByClientNo(widget.client.clientNo!);
    if (clientExtra != null) {
      setState(() {
      politicalPartyController.text =
            _convertHtmlToText(clientExtra?.politicalParty ?? "");
        presentPositionController.text =
            _convertHtmlToText(clientExtra?.presentPosition ?? "");
        hobbiesController.text = _convertHtmlToText(clientExtra?.hobbies ?? "");
        companiesController.text =
            _convertHtmlToText(clientExtra?.companies ?? "");

      });
    }
  }

  @override
  void dispose() {
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    dateOfBirthController.dispose();
    telephoneController.dispose();
    emailController.dispose();
    placeOfWorkController.dispose();
    associatesController.dispose();
    friendsController.dispose();
    politicalPartyController.dispose();
    presentPositionController.dispose();
    hobbiesController.dispose();
    companiesController.dispose();
    _titleIdNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Client Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isUser)
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (isEditing) {
                  DateTime? selectedDate;

                  try {
                    selectedDate = DateFormat('dd/MM/yyyy')
                        .parse(dateOfBirthController.text);
                  } catch (e) {
                    selectedDate = null;
                  }
                  Client client = Client(
                    associates:  associatesController.text.replaceAll('\n', '<br>'),
                    clientNo: widget.client.clientNo,
                    dateOfBirth: selectedDate,
                    email: emailController.text,
                    firstName: firstNameController.text,
                    friends:friendsController.text.replaceAll('\n', '<br>'),
                    lastName: lastNameController.text,
                    id: widget.client.id,
                    middleName: middleNameController.text,
                    placeOfWork:  placeOfWorkController.text.replaceAll('\n', '<br>'),
                    telephone: telephoneController.text,
                    titleId: _titleIdNotifier.value,
                  );
                  ClientExtra extra = ClientExtra(
                    clientNo: widget.client.clientNo,
                    companies: companiesController.text.replaceAll('\n', '<br>'),
                    hobbies:   hobbiesController.text.replaceAll('\n', '<br>'),
                    id: clientExtra?.id,
                    politicalParty: politicalPartyController.text.replaceAll('\n', '<br>'),
                    presentPosition:  presentPositionController.text.replaceAll('\n', '<br>'),
                  );
                  await clientProvider.updateClient(client, extra, () {
                    setState(() {
                      widget.client = client;
                      clientExtra = extra;
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
    return Consumer<ClientProvider>(builder: (context, clientProvider, child) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormFieldWidget(
                controller: firstNameController,
                label: 'First Name',
                htmlData: widget.client.firstName,
                isEditing: isEditing,
                icon: Icons.person,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: middleNameController,
                label: 'Middle Name',
                htmlData: widget.client.middleName,
                isEditing: isEditing,
                icon: Icons.person_pin,
              ),
              const SizedBox(height: 8.0),
              FormFieldWidget(
                controller: lastNameController,
                label: 'Last Name',
                htmlData: widget.client.lastName,
                isEditing: isEditing,
                icon: Icons.person_outline,
              ),
              isEditing ? const SizedBox() : const SizedBox(height: 8.0),
              isEditing
                  ? const SizedBox()
                  : TextFieldWidget(
                      icon: Icons.account_circle,
                      label: "Client Number",
                      htmlData: widget.client.clientNo.toString(),
                    ),
              const SizedBox(height: 8.0),
              isEditing
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person, size: 20),
                        const SizedBox(width: 8.0),
                        Expanded(
                            child: ValueListenableBuilder<int?>(
                          valueListenable: _titleIdNotifier,
                          builder: (context, value, child) {
                            return DropdownButtonFormField<int>(
                              value: value,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items:
                                  clientProvider.titles.keys.map((int typeId) {
                                return DropdownMenuItem<int>(
                                  value: typeId,
                                  child: Text(clientProvider
                                      .getClientTitleDescription(typeId)),
                                );
                              }).toList(),
                              onChanged: (int? newTypeId) {
                                if (newTypeId != null) {
                                  _titleIdNotifier.value = newTypeId;
                                }
                              },
                            );
                          },
                        ))
                      ],
                    )
                  : TextFieldWidget(
                      icon: Icons.person,
                      label: "Title",
                      htmlData: clientProvider
                          .getClientTitleDescription(widget.client.titleId),
                    ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            isEditing
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  widget.client.dateOfBirth ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.client.dateOfBirth = selectedDate;
                                dateOfBirthController.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate);
                              });
                              // Save changes to the database
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Date Of Birth',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: dateOfBirthController,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : TextFieldWidget(
                    icon: Icons.calendar_today,
                    label: "Date Of Birth",
                    htmlData: widget.client.dateOfBirth != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(widget.client.dateOfBirth!)
                        : 'N/A',
                  ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: friendsController,
              label: 'Friends',
              htmlData: widget.client.friends,
              isEditing: isEditing,
              icon: Icons.people,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: associatesController,
              label: 'Associates',
              htmlData: widget.client.associates,
              isEditing: isEditing,
              icon: Icons.people,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: telephoneController,
              label: 'Telephone',
              htmlData: widget.client.telephone,
              isEditing: isEditing,
              icon: Icons.phone,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: emailController,
              label: 'Email',
              htmlData: widget.client.email,
              isEditing: isEditing,
              icon: Icons.email,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: placeOfWorkController,
              label: 'Place of Work',
              htmlData: widget.client.placeOfWork,
              isEditing: isEditing,
              icon: Icons.business,
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
              'Client Extra',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            FormFieldWidget(
              controller: politicalPartyController,
              label: 'Political Party',
              htmlData: clientExtra?.politicalParty,
              isEditing: isEditing,
              icon: Icons.how_to_vote,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: presentPositionController,
              label: 'Present Position',
              htmlData: clientExtra?.presentPosition,
              
              isEditing: isEditing,
              icon: Icons.work,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: hobbiesController,
              label: 'Hobbies',
              htmlData: clientExtra?.hobbies,
              isEditing: isEditing,
              icon: Icons.sports_basketball,
            ),
            const SizedBox(height: 8.0),
            FormFieldWidget(
              controller: companiesController,
              label: 'Companies',
              htmlData: clientExtra?.companies,
              isEditing: isEditing,
              icon: Icons.business_center,
            ),
          ],
        ),
      ),
    );
  }
}
