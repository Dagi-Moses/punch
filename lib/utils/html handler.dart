import 'package:flutter/material.dart';

class HtmlTextHandler {
  final TextEditingController controller;
  final Function(String) onTextChanged;
  final String initialText;

  HtmlTextHandler({
    required this.controller,
    required this.onTextChanged,
    required this.initialText,
  }) {
    controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    String currentText = controller.text;
    String updatedText = _convertHtmlToText(currentText);
  
    if (updatedText != initialText) {
      onTextChanged(updatedText);
    }
  }

  String _convertHtmlToText(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<br\s*/?>'), '\n');
  }

  String convertTextToHtml(String text) {
    return text.replaceAll('\n', '<br>');
  }

  void dispose() {
    controller.dispose();
  }
}
