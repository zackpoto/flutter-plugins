part of cough_detection;

class PathHandler {

  static Future<String> getPath(String filename) async {
      String path = (await getApplicationDocumentsDirectory()).path;
      path += '/spectrograms/$filename.png';
      return path;
  }
}
