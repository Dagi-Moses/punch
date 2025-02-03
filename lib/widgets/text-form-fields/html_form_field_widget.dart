import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// ignore: must_be_immutable

Widget buildTextField({
  required bool isEditing,
  required TextEditingController controller,
  required String label,
  bool? enabled = true,
  TextInputType keyboardType = TextInputType.multiline,
  int? maxLines,
  void Function(String)? onChanged,
  String? Function(String?)? validator, // Optional validator
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLines: maxLines,
          readOnly: !(isEditing && enabled!),
          cursorColor: Colors.red,
          keyboardType: keyboardType,
          controller: controller,
          validator: validator, // Apply the validator if provided
          onChanged: onChanged,
          decoration: InputDecoration(
            // filled: true,
            // fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    ),
  );
}

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? htmlData;
  final bool isEditing;
  final IconData icon;
  bool? enabled = true;

  FormFieldWidget(
      {super.key,
      required this.controller,
      required this.label,
      this.htmlData,
      required this.isEditing,
      required this.icon,
      this.enabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8.0),
        isEditing
            ? Expanded(
                child: TextFormField(
                  enabled: enabled,
                  controller: controller,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              )
            : Flexible(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '$label: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      if (htmlData != null)
                        WidgetSpan(
                          child: Html(
                            data: htmlData,
                            style: {
                              "body": Style(
                                fontSize: FontSize(16),
                                color: Colors.black,
                              ),
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String label;
  final String? htmlData;

  final IconData icon;

  const TextFieldWidget({
    super.key,
    required this.label,
    this.htmlData,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8.0),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .grey[900]), // Custom styling for "Place of Work:"
                ),
                WidgetSpan(
                  child: Html(
                    data:
                        htmlData, // Render the HTML content for the place of work
                    style: {
                      "body": Style(
                        fontSize: FontSize(16), // Styling for the HTML content
                        color: Colors.black, // Color for the placeOfWork text
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



// class FormFieldWidget extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String? htmlData;
//   final bool isEditing;
//   final IconData icon;
//   bool? enabled = true;

//   FormFieldWidget(
//       {super.key,
//       required this.controller,
//       required this.label,
//       this.htmlData,
//       required this.isEditing,
//       required this.icon,
//       this.enabled});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 20),
//         const SizedBox(width: 8.0),
//         isEditing
//             ? Expanded(
//                 child: TextFormField(
//                   enabled: enabled,
//                   controller: controller,
//                   maxLines: null,
//                   decoration: InputDecoration(
//                     labelText: label,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   keyboardType: TextInputType.multiline,
//                 ),
//               )
//             : Flexible(
//                 child: RichText(
//                   text: TextSpan(
//                     style: const TextStyle(fontSize: 16, color: Colors.black),
//                     children: [
//                       TextSpan(
//                         text: '$label: ',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[900],
//                         ),
//                       ),
//                       if (htmlData != null)
//                         WidgetSpan(
//                           child: Html(
//                             data: htmlData,
//                             style: {
//                               "body": Style(
//                                 fontSize: FontSize(16),
//                                 color: Colors.black,
//                               ),
//                             },
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//       ],
//     );
//   }
// }
