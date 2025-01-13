import 'dart:typed_data';
import 'dart:html' as html;

void downloadImage(Uint8List imageBytes, String fileName) {
  // Logic for downloading the image
  final blob = html.Blob([imageBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
