import 'dart:convert';
import 'dart:html' as html;

Future<String> saveBytes(String filename, List<int> bytes) async {
  final content = base64Encode(bytes);
  final anchor =
      html.AnchorElement(href: 'data:application/octet-stream;base64,$content')
        ..download = filename
        ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return filename;
}
