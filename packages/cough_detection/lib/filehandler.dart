part of cough_detection;

class FileHandler {
  static String delimiter = '\n';
  static double threshold = 0.85;

  static Future<File> _coughsFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = appDocDir.path;
    print(path);
    return File('$path/coughs.json');
  }

  static Future<List<Cough>> readCoughs() async {
    File file = await _coughsFile();

    /// Read file content as one big string
    String content = await file.readAsString();

    /// Split content into lines by delimiting them
    List<String> lines = content.split(delimiter);

    /// Remove last entry since it is always empty
    /// Then convert each line to JSON, and then to Dart Map<T> objects
    /// Lastly convert Map objects to Cough objects
    List<Cough> coughs = lines
        .sublist(0, lines.length - 1)
        .map((e) => json.decode(e))
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Cough.fromJson(e))
        .toList();

    return coughs;
  }

  static void writeCoughToFile(Cough c) async {
    /// Set up file
    File file = await _coughsFile();

    /// Write data to file
    String coughString = json.encode(c.toJson());
    print('Storing: $coughString');
    await file.writeAsString('$coughString$delimiter',
        mode: FileMode.writeOnlyAppend);
  }
}
