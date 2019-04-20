import 'dart/DBClient.dart';
import 'dart:html';
import 'dart/UIManager.dart';

void main() {
  querySelector("#output").text += " Dart running.";

  DBClient dbClient = new DBClient();
  dbClient.ping();

  new UIManager();
}
