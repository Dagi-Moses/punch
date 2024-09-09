import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class FormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? htmlData;
  final bool isEditing;
  final IconData icon;

  FormFieldWidget({
    required this.controller,
    required this.label,
    this.htmlData,
    required this.isEditing,
    required this.icon,
  });

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

  TextFieldWidget({
 
    required this.label,
    this.htmlData,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '$label: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[
                                          900]), // Custom styling for "Place of Work:"
                                ),
                                WidgetSpan(
                                  child: Html(
                                    data:htmlData, // Render the HTML content for the place of work
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(
                                            16), // Styling for the HTML content
                                        color: Colors
                                            .black, // Color for the placeOfWork text
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
