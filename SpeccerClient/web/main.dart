import 'dart/DBClient.dart';
import 'dart:html';
import 'dart/UIManager.dart';

void main() {
  querySelector("#output").text += " Dart running.";
  Map<String, dynamic> pingData = new Map();
  pingData["~"] = "ping";

  Request.makeRequest(pingData).then((Map<String, dynamic> data) {
    querySelector("#output").text += " Response '${data["~"]}' received from server.";
  });

  new UIManager();
}
