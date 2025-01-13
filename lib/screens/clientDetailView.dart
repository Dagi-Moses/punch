import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/functions/downloadImage.dart';
import 'package:punch/models/myModels/clientExtraModel.dart';
import 'package:punch/models/myModels/clientModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/authProvider.dart';
import 'package:punch/providers/clientExtraProvider.dart';
import 'package:punch/providers/clientProvider.dart';

import 'package:punch/utils/html%20handler.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/editableImagePicker.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

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

  late TextEditingController addressController;
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
  late TextEditingController imageDescriptionController;
  late TextEditingController ageController;
  late TextEditingController clientNoController;

  ClientExtra? clientExtra;

  late HtmlTextHandler addressHandler;
  late HtmlTextHandler placeOfWorkHandler;
  late HtmlTextHandler associatesHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler presentPositionHandler;
  late HtmlTextHandler politicalPartyHandler;
  late HtmlTextHandler hobbiesHandler;
  late HtmlTextHandler companiesHandler;
  late HtmlTextHandler descriptionHandler;

  @override
  void initState() {
    super.initState();
    Initialize();
  }

  void Initialize() async {
    imageDescriptionController =
        TextEditingController(text: _convertHtmlToText(widget.client.description ?? ""));

    clientNoController =
        TextEditingController(text: widget.client.clientNo.toString()??"");
    ageController =
        TextEditingController(text: widget.client.age?.toString()?? "");
    lastNameController = TextEditingController(
        text: _convertHtmlToText(widget.client.lastName ?? ""));
    addressController = TextEditingController(
        text: _convertHtmlToText(widget.client.address ?? ""));
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

    await _fetchClientExtra();

    companiesHandler = HtmlTextHandler(
      controller: companiesController,
      onTextChanged: (text) {
        setState(() {
          clientExtra?.companies = text;
        });
      },
      initialText: companiesController.text,
    );

    addressHandler = HtmlTextHandler(
      controller: addressController,
      onTextChanged: (text) {
        setState(() {
          widget.client.address = text;
        });
      },
      initialText: addressController.text,
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

    descriptionHandler = HtmlTextHandler(
      controller: imageDescriptionController,
      onTextChanged: (text) {
        setState(() {
          widget.client.description = text;
        });
      },
      initialText: imageDescriptionController.text,
    );
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
    ageController.dispose();
    imageDescriptionController.dispose();
    addressController.dispose();
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
    clientNoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final isUser = auth.user?.loginId == UserRole.user;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
              automaticallyImplyLeading: false,
          title: const TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: "Client Details"),
              Tab(text: "Image"),
            ],
          ),
        ),
        floatingActionButton: !isUser
            ?
            
            clientProvider.updateloading
                ? FloatingActionButton(
                    onPressed:
                        null, // Disable button interaction while loading.
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : 
            
             FloatingActionButton(
                tooltip: 'Edit Client',
                child: Icon(isEditing ? Icons.save : Icons.edit),
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
                      description: imageDescriptionController.text
                          .replaceAll('\n', '<br>'),
                      image: clientProvider.compressedImage,
                      address: addressController.text.replaceAll('\n', '<br>'),
                      associates:
                          associatesController.text.replaceAll('\n', '<br>'),
                      clientNo: widget.client.clientNo,
                      dateOfBirth: selectedDate,
                      email: emailController.text,
                      firstName: firstNameController.text,
                      friends: friendsController.text.replaceAll('\n', '<br>'),
                      lastName: lastNameController.text,
                      id: widget.client.id,
                      middleName: middleNameController.text,
                      placeOfWork:
                          placeOfWorkController.text.replaceAll('\n', '<br>'),
                      telephone: telephoneController.text,
                      titleId: _titleIdNotifier.value,
                    );
                    ClientExtra extra = ClientExtra(
                      clientNo: widget.client.clientNo,
                      companies:
                          companiesController.text.replaceAll('\n', '<br>'),
                      hobbies: hobbiesController.text.replaceAll('\n', '<br>'),
                      id: clientExtra?.id,
                      politicalParty: politicalPartyController.text
                          .replaceAll('\n', '<br>'),
                      presentPosition: presentPositionController.text
                          .replaceAll('\n', '<br>'),
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
              )
            : null,
        body: TabBarView(
          children: [
            SingleChildScrollView(child: _buildHeaderSection(clientProvider)),
            SingleChildScrollView(child: _buildImageSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Card(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField(
                  isEditing: isEditing,
                  controller: imageDescriptionController,
                  label: 'Image Description',
                ),
                const SizedBox(height: 8.0),
                _buildImagePicker(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final clientProvider = Provider.of<ClientProvider>(context);
    return EditableImagePicker(
      label: "Image",
      isEditing: isEditing,
      image: widget.client.image,
      onPickImage: clientProvider.pickImage,
      onImageChanged: (newImage) {
        setState(() {
          widget.client.image = newImage;
        });
      },
      onRemoveImage: () {
        setState(() {
          widget.client.image = null;
          clientProvider.compressedImage = null;
        });
      },
      onDownloadImage: () {
        if (widget.client.image != null) {
          downloadImage(widget.client.image!, "client_image.png");
        }
      },
    );
  }

  Widget _buildTitle(ClientProvider clientProvider) {
    return ValueListenableBuilder<int?>(
      valueListenable: _titleIdNotifier,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    // Change to your desired border color
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonFormField<int>(
                  value: value,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: InputBorder.none, // Remove the inner border
                  ),
                  items: clientProvider.titles.keys.map((int typeId) {
                    return DropdownMenuItem<int>(
                      enabled: isEditing,
                      value: typeId,
                      child: Text(
                          clientProvider.getClientTitleDescription(typeId)),
                    );
                  }).toList(),
                  onChanged: isEditing
                      ? (int? newTypeId) {
                          if (newTypeId != null) {
                            _titleIdNotifier.value = newTypeId;
                            widget.client.titleId = newTypeId;
                            // Save changes to the database (implement this logic)
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDate() {
    return EditableDateField(
      label: "Date of Birth",
      isEditing: isEditing,
      selectedDate: widget.client.dateOfBirth,
      controller: dateOfBirthController,
      onDateChanged: (newDate) {
        setState(() {
          widget.client.dateOfBirth = newDate;
          dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(newDate);
          final aniyr = DateTime.now().year - newDate.year;
          widget.client.age = aniyr;
          ageController.text = aniyr.toString();
        });
      },
    );
  }

  Widget _buildHeaderSection(ClientProvider clientProvider) {
    return Center(
      child: ResponsiveWrapper(
        maxWidth: 800,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Card(
            elevation: 4.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child:  buildTextField(
                          isEditing: isEditing,
                          controller: firstNameController,
                          label: 'First Name',
                          maxLines: 1
                        ),
                      ),
                      const SizedBox(width: 16),
                    Expanded(child:   buildTextField(
                          isEditing: isEditing,
                          controller: middleNameController,
                          label: 'Middle Name',
                           maxLines: 1
                        ),
                      ),
                  ],),
                  Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                    Expanded(child: 
                  buildTextField(
                          isEditing: isEditing,
                          controller: lastNameController,
                          label: 'Last Name',
                           maxLines: 1
                        ),
                      ),

                       const SizedBox(width: 16),
                       Expanded(child: 
                  buildTextField(
                    isEditing: isEditing,
                    controller: emailController,
                    label: 'Email',
                     maxLines: 1
                  ),)
                  ],),
                 
                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: buildTextField(
                            isEditing: isEditing,
                            controller: clientNoController,
                            label: "Client Number",
                             maxLines: 1,
                            enabled: false),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTitle(clientProvider)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDate()),
                    ],
                  ),

                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child:  buildTextField(
                            isEditing: isEditing,
                            controller: ageController,
                            label: "Age",
                             maxLines: 1,
                            enabled: false),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child:   buildTextField(
                          isEditing: isEditing,
                          controller: telephoneController,
                          label: 'Telephone',
                           maxLines: 1,
                        ),
                      ),
                      
                    ],
                  ),
                 
                  buildTextField(
                    isEditing: isEditing,
                    controller: friendsController,
                    label: 'Friends',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: associatesController,
                    label: 'Associates',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: addressController,
                    label: 'Address',
                  ),
                
                  buildTextField(
                    isEditing: isEditing,
                    controller: placeOfWorkController,
                    label: 'Place of Work',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: politicalPartyController,
                    label: 'Political Party',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: presentPositionController,
                    label: 'Present Position',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: hobbiesController,
                    label: 'Hobbies',
                  ),
                  buildTextField(
                    isEditing: isEditing,
                    controller: companiesController,
                    label: 'Companies',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
