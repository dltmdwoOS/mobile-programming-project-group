import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<bool> doesFileExist(String path) async {
  try {
    final file = File(path);
    return await file.exists();
  } catch (e) {
    return false;
  }
}

Future<void> saveJsonToFile(Map<String, dynamic> jsonData, String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = "${directory.path}/$fileName";
  final file = File(filePath);

  if (!await file.parent.exists()) {
    await file.parent.create(recursive: true);
  }

  await file.writeAsString(jsonEncode(jsonData), flush: true);
}

Future<Map<String, Map<String, dynamic>>?> readJsonFromFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/$fileName";
    final file = File(filePath);

    if (!await file.exists()) {
      return null;
    }

    final contents = await file.readAsString();
    final Map<String, dynamic> decodedData = jsonDecode(contents);

    return decodedData.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, value);
      } else {
        throw FormatException("Invalid data format for key: $key");
      }
    });
  } catch (e) {
    print("Error reading JSON file: $e");
    return null;
  }
}
