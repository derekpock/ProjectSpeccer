import "dart/DBClient.dart";
import 'dart:html';

void main() {
  querySelector('#output').text += 'Your Dart app is running.';
  Map<String, String> data = new Map();
  data["~"] = "ping";
  new Request(data);
}
