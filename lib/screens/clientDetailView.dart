import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/providers/clientProvider.dart';

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
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    lastNameController =
        TextEditingController(text: widget.client.lastName ?? "");
    firstNameController =
        TextEditingController(text: widget.client.firstName ?? "");
    middleNameController =
        TextEditingController(text: widget.client.middleName ?? "");
    telephoneController =
        TextEditingController(text: widget.client.telephone ?? "");
    emailController = TextEditingController(text: widget.client.email ?? '');
    placeOfWorkController =
        TextEditingController(text: widget.client.placeOfWork ?? "");
    associatesController =
        TextEditingController(text: widget.client.associates ?? "");
    friendsController =
        TextEditingController(text: widget.client.friends ?? "");

    // Initialize clientExtra fields as empty until fetched
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
    _fetchClientExtra();
  }

  Future<void> _fetchClientExtra() async {
    final clientExtraProvider = Provider.of<ClientExtraProvider>(context, listen: false);
    clientExtra =
        await clientExtraProvider.getClientExtraByClientNo(widget.client.clientNo!);
    if (clientExtra != null) {
      setState(() {
        politicalPartyController.text = clientExtra?.politicalParty ?? "";
        presentPositionController.text = clientExtra?.presentPosition ?? "";
        hobbiesController.text = clientExtra?.hobbies ?? "";
        companiesController.text = clientExtra?.companies ?? "";
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
          if(!isUser)
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (isEditing) {
                print("clicked");
                 DateTime? selectedDate;

                try {
                  selectedDate =
                      DateFormat('dd/MM/yyyy').parse(dateOfBirthController.text);
                } catch (e) {
                  // Handle parsing error
                  print("Error parsing date: $e");
                }


                Client client = Client(
                  associates: associatesController.text,
                  clientNo: widget.client.clientNo,
                  dateOfBirth:selectedDate,
                  email: emailController.text,
                  firstName: firstNameController.text,
                  friends: friendsController.text,
                  lastName: lastNameController.text,
                  id: widget.client.id,
                  middleName: middleNameController.text,
                  placeOfWork: placeOfWorkController.text,
                  telephone: telephoneController.text,
                  titleId: _titleIdNotifier.value,
                );
                ClientExtra extra = ClientExtra(
                  clientNo: widget.client.clientNo,
                  companies: companiesController.text,
                  hobbies: hobbiesController.text,
                  id: clientExtra?.id ?? widget.client.id,
                  politicalParty: politicalPartyController.text,
                  presentPosition: presentPositionController.text,
                );
                await clientProvider.updateClient(client, extra, () {
                  setState(() {
                    widget.client = client;
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
              Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'First Name: ${widget.client.firstName}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.person_pin, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: middleNameController,
                            decoration: InputDecoration(
                              labelText: 'Middle Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Middle Name: ${widget.client.middleName}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
                          child: TextFormField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          'Last Name: ${widget.client.lastName}',
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
                        const Icon(Icons.account_circle, size: 20),
                        const SizedBox(width: 8.0),
                        Text(
                          'Client No: ${widget.client.clientNo}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8.0),
                  isEditing
                      ? Expanded(
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
                      : Text(
                          'Title: ${clientProvider.getClientTitleDescription(widget.client.titleId)}',
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
                                  widget.client.dateOfBirth ?? DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                widget.client.dateOfBirth = selectedDate;
                                dateOfBirthController.text = DateFormat('dd/MM/yyyy')
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
                              controller: dateOfBirthController,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        'Date: ${widget.client.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(widget.client.dateOfBirth!) : 'N/A'}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: friendsController,
                          decoration: InputDecoration(
                            labelText: 'Friends',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Friends: ${widget.client.friends}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: associatesController,
                          decoration: InputDecoration(
                            labelText: 'Associates',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Associates: ${widget.client.associates}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),

             Row(
              children: [
                const Icon(Icons.phone, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: telephoneController,
                          decoration: InputDecoration(
                            labelText: 'Telephone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Telephone: ${widget.client.telephone}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
           
            const SizedBox(height: 8.0),
             Row(
              children: [
                const Icon(Icons.email, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Email: ${widget.client.email}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.business, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: placeOfWorkController,
                          decoration: InputDecoration(
                            labelText: 'Place of Work',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Place of Work: ${widget.client.placeOfWork}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
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
            Row(
              children: [
                const Icon(Icons.how_to_vote, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: politicalPartyController,
                          decoration: InputDecoration(
                            labelText: 'Political Party',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Political Party: ${politicalPartyController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            
            Row(
              children: [
                const Icon(Icons.work, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: presentPositionController,
                          decoration: InputDecoration(
                            labelText: 'Present Position',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Present Position: ${presentPositionController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),


     
           
            const SizedBox(height: 8.0),
             Row(
              children: [
                const Icon(Icons.sports_basketball, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: hobbiesController,
                          decoration: InputDecoration(
                            labelText: 'Hobbies',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Hobbies: ${hobbiesController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.business_center, size: 20),
                const SizedBox(width: 8.0),
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          controller: companiesController,
                          decoration: InputDecoration(
                            labelText: 'Companies',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : Text(
                          'Companies: ${companiesController.text}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
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
