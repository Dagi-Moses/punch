
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:punch/functions/downloadImage.dart';
import 'package:punch/models/myModels/anniversaryModel.dart';
import 'package:punch/models/myModels/userModel.dart';
import 'package:punch/providers/anniversaryProvider.dart';
import 'package:punch/providers/authProvider.dart';

import 'package:punch/utils/html%20handler.dart';
import 'package:punch/widgets/inputs/dateFields.dart';
import 'package:punch/widgets/inputs/editableImagePicker.dart';
import 'package:punch/widgets/text-form-fields/html_form_field_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:html' as html;

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
  late TextEditingController imageDescriptionController;

  late HtmlTextHandler placedByHandler;
  late HtmlTextHandler associatesHandler;
  late HtmlTextHandler friendsHandler;
  late HtmlTextHandler descriptionHandler;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.anniversary.name ?? "");
    imageDescriptionController =
        TextEditingController(text:  _convertHtmlToText(widget.anniversary.description ?? ""));
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

    descriptionHandler = HtmlTextHandler(
      controller: imageDescriptionController,
      onTextChanged: (text) {
        setState(() {
          widget.anniversary.description = text;
        });
      },
      initialText: imageDescriptionController.text,
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
    imageDescriptionController.dispose();
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

    return
    
     DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            unselectedLabelStyle: TextStyle(color: Colors.black, fontWeight:FontWeight.bold),
            labelStyle: TextStyle(fontWeight:FontWeight.bold),
            indicatorColor: Colors.red,
            tabs: [
              Tab(text: "Anniversary Details"),
              Tab(text: "Image"),
            ],
          ),
        ),
        floatingActionButton: !isUser
            ?
           
            
            anniversaryProvider.updateloading
                ? const FloatingActionButton(
                    onPressed:
                        null, // Disable button interaction while loading.
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : 
             FloatingActionButton(
                tooltip: 'Edit Anniversary',
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
                        placedByName: placedByNameController.text
                            .replaceAll('\n', '<br>'),
                        description: imageDescriptionController.text
                            .replaceAll('\n', '<br>'),
                        placedByAddress: placedByAddressController.text,
                        placedByPhone: placedByPhoneController.text,
                        friends:
                            friendsController.text.replaceAll('\n', '<br>'),
                        associates:
                            associatesController.text.replaceAll('\n', '<br>'),
                        anniversaryYear:
                            int.tryParse(anniversaryYearController.text),
                        paperId: _paperIdNotifier.value,
                        date: selectedDate,
                        anniversaryTypeId: _anniversaryTypeNotifier.value,
                        image: anniversaryProvider.compressedImage);

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
                child: Icon(isEditing ? Icons.save : Icons.edit),
              )
            : null,
        body: TabBarView(
          children: [
            SingleChildScrollView(
                child: _buildHeaderSection(anniversaryProvider)),
            SingleChildScrollView(child:  _buildImageSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildDate(){
    return  EditableDateField(
          label: "Date",
          isEditing: isEditing,
          selectedDate: widget.anniversary.date,
          controller: _dateController,
          onDateChanged: (newDate) {
            setState(() {
              widget.anniversary.date = newDate;
              _dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
              final aniyr = DateTime.now().year - newDate.year;
              widget.anniversary.anniversaryYear = aniyr;
              anniversaryYearController.text = aniyr.toString();
            });
          },
        );
  }


  Widget _buildPaperType(AnniversaryProvider anniversaryProvider) {
    return ValueListenableBuilder<int?>(

      valueListenable: _paperIdNotifier,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paper",
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
                decoration:const InputDecoration(
                  
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: InputBorder.none, // Remove the inner border
                ),
                
                items: anniversaryProvider.paperTypes.keys.map((int typeId) {
                  return DropdownMenuItem<int>(
                       enabled: isEditing,
                    value: typeId,
                    child: Text(
                        anniversaryProvider.getPaperTypeDescription(typeId)),
                  );
                }).toList(),
               onChanged: isEditing
                  ? (int? newTypeId) {
                      if (newTypeId != null) {
                        _paperIdNotifier.value = newTypeId;
                        widget.anniversary.paperId = newTypeId;
                        // Save changes to the database (implement this logic)
                      }
                    }
                  : null, 
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnniversaryType(AnniversaryProvider anniversaryProvider) {
    return ValueListenableBuilder<int?>(
      valueListenable: _anniversaryTypeNotifier,
      builder: (context, value, child) {
        // If the current value is null or not in the list, set it to a default or null value
        if (value == null ||
            !anniversaryProvider.anniversaryTypes.keys.contains(value)) {
          value = null; // or set to a default value that exists in your list
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Anniversary Type",
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
                    color:
                    Colors.grey,
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
                items:
                    anniversaryProvider.anniversaryTypes.keys.map((int typeId) {
                  return DropdownMenuItem<int>(
                    enabled: isEditing,
                    value: typeId,
                    child: Text(
                      anniversaryProvider.getAnniversaryTypeDescription(typeId),
                    ),
                  );
                }).toList(),
                onChanged: isEditing?(int? newTypeId) {
                  if (newTypeId != null) {
                    _anniversaryTypeNotifier.value = newTypeId;
                    widget.anniversary.anniversaryTypeId = newTypeId;
                    // Save changes to the database (implement this logic)
                  }
                }:null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection(AnniversaryProvider anniversaryProvider) {
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
                  buildTextField(
                           isEditing: isEditing,
                    controller: nameController,
                    label: "Name",
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: _buildAnniversaryType(anniversaryProvider)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                                 isEditing: isEditing,
                          controller: placedByPhoneController,
                          label: 'Placed by Phone',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPaperType(anniversaryProvider)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildDate()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildTextField(
                                 isEditing: isEditing,
                            controller: anniversaryYearController,
                            label: "Anniversary Year",
                             maxLines: 1,
                            enabled: false),
                      ),
                    ],
                  ),
                  buildTextField(
                           isEditing: isEditing,
                    controller: placedByNameController,
                    label: "Placed by Name",
                  ),
                  
                  buildTextField(
                           isEditing: isEditing,
                    controller: placedByAddressController,
                    label: 'Placed by Address',
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
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
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
   final anniversaryProvider = Provider.of<AnniversaryProvider>(context);
   return  EditableImagePicker(
          label: "Image",
          isEditing: isEditing,
          image: widget.anniversary.image,
          onPickImage: anniversaryProvider.pickImage,
          onImageChanged: (newImage) {
            setState(() {
              widget.anniversary.image = newImage;
            });
          },
          onRemoveImage: () {
            setState(() {
              widget.anniversary.image = null;
              anniversaryProvider.compressedImage = null;
            });
          },
          onDownloadImage: () {
            if (widget.anniversary.image != null) {
              downloadImage(widget.anniversary.image!, "anniversary_image.png");
            }
          },
        );
  }

}
