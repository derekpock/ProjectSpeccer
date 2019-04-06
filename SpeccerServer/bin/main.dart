import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:postgres/postgres.dart';

const utf8Codec = Utf8Codec();
const PORT = 58524;
const HOST = "localhost";
const CROSS_ORIGIN_ACCESS = "http://localhost:53322";

Future main(List<String> arguments) async {
  print("running");

//  var serverContext = SecurityContext();
//  serverContext.useCertificateChain("path/to/server_chain.pem");
//  serverContext.usePrivateKey("path/to/server_key.pen", password: "password");
//
//  var server = await HttpServer.bindSecure("localhost", 58524, serverContext);

  var server = await HttpServer.bind(HOST, PORT);

  await for (HttpRequest request in server) {
    // Get request information
    ContentType contentType = request.headers.contentType;
    HttpResponse response = request.response;
    bool setRequest = request.method == "POST";

    // Allow this to be accessed from CROSS_ORIGIN_ACCESS websites.
    response.headers.add("Access-Control-Allow-Origin", CROSS_ORIGIN_ACCESS);

    if (setRequest) {
      // Parse a request from the client.
      try {
        String stringData = await request.transform(utf8Codec.decoder).join();
        Map<String, dynamic> data =
            new Map<String, dynamic>.from(jsonDecode(stringData));
        parseClientInfo(response, data);
      } catch (e1) {
        // Error in parsing info; attempt to send a response.
        try {
          response
            ..statusCode = HttpStatus.internalServerError
            ..write("");
        } catch (e2) {}
        print("exception in parsing: $e1");
      }
    } else {
      // Invalid request from client; attempt to send a response.
      try {
        response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write("");
      } catch (e3) {}
      print("unsupported req: ${request.method} ${contentType?.mimeType}.");
    }
    await response.close();
  }
}

void parseClientInfo(HttpResponse response, Map<String, dynamic> inData) {
  Map<String, String> outData = new Map<String, String>();

  if (inData.containsKey("~")) {
    response.statusCode = HttpStatus.ok;

    switch (inData["~"]) {
      case "ping":
        outData["~"] = "pong";
        print("pong");
        break;
      case "dbping":
        dbConnection();
        break;
      default:
        response.statusCode = HttpStatus.notAcceptable;
    }
  } else {
    response.statusCode = HttpStatus.notAcceptable;
  }
  response.write(jsonEncode(outData));
}

void dbConnection() async {
  var connection = new PostgreSQLConnection("localhost", 5432, "postgres",
      username: "dlzp_client", password: "temppass");
  await connection.open();
  //...
}
