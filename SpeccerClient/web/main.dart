import "dart/DBClient.dart";
import 'dart:html';

void main() {
  querySelector("#output").text += " Dart running.";
  Map<String, dynamic> pingData = new Map();
  pingData["~"] = "ping";
  Request.makeRequest(pingData).then((Map<String, dynamic> data) {
    querySelector("#output").text += " Response '${data["~"]}' received from server.";
  });

  Map<String, dynamic> data = new Map();
  data["~"] = "dbquery";
  data["query"] = "SELECT * FROM test_table;";
  new Request(data, null);
}
