import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:pedantic/pedantic.dart';
import 'package:postgres/postgres.dart';

const utf8Codec = Utf8Codec();
const PORT = 58524;
const HOST = "dlzpserver.noip.me";
const CROSS_ORIGIN_ACCESS = "https://dlzpserver.noip.me";

void main(List<String> arguments) async {
  print("Server started at ${DateTime.now().toString()}");

  List<InternetAddress> serverIps = await InternetAddress.lookup(HOST);
  print("Accepting connections from ${CROSS_ORIGIN_ACCESS} or any address from ${serverIps}.");

  SecurityContext serverContext = SecurityContext();
  serverContext.useCertificateChain("/etc/apache2/ssl.crt/fullchain.pem");
  serverContext.usePrivateKey("/etc/apache2/ssl.key/key.pem");

  HttpServer server = await HttpServer.bindSecure(InternetAddress.anyIPv4, PORT, serverContext);

  await for (HttpRequest request in server) {
    // Get request information.
    ContentType contentType = request.headers.contentType;
    HttpResponse response = request.response;
    bool setRequest = request.method == "POST";

    // Set cross origin access.
    // Only requests from our host or from our address are allowed.
    if (serverIps.contains(request.connectionInfo.remoteAddress)) {
      response.headers
          .add("Access-Control-Allow-Origin", request.headers.value("origin"));
    } else {
      response.headers.add("Access-Control-Allow-Origin", CROSS_ORIGIN_ACCESS);
    }

    if (setRequest) {
      // Parse a request from the client.
      new Request(request);
    } else {
      // Invalid request from client; attempt to send a response.
      try {
        response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write("");
      } catch (e3) {}
      print("Unsupported request: ${request.method} ${contentType?.mimeType}.");
    }
  }
}

class Request {

  HttpRequest _request;
  HttpResponse _response;
  Map<String, dynamic> _inData;
  Map<String, dynamic> _outData;
  PostgreSQLConnection _db;

  Request(HttpRequest request) {
    _request = request;
    _response = request.response;
    _getClientDataString()
        .then((String stringData) => _inData = new Map<String, dynamic>.from(jsonDecode(stringData)))
        .then((_) => _parseClientInfo())
        .then((_) => _closeRequest())
        .catchError((error) => errorAttemptResponse(error, "Error during client future chain"))
        .then((_) => _closeRequest());;
  }

  void errorAttemptResponse(Exception e, String errorMessage) {
    try {
      _response
        ..statusCode = HttpStatus.internalServerError
        ..write("");
    } catch (e2) {}
    print("$errorMessage: $e");
  }

  Future<String> _getClientDataString() {
    return _request.transform(utf8Codec.decoder).join().catchError((e) {
      errorAttemptResponse(e, "Error joining client data");
    });
  }

  Future _parseClientInfo() {
    Future f = Future((){});
    _outData = new Map<String, dynamic>();
    if (_inData.containsKey("~")) {
      _response.statusCode = HttpStatus.ok;

      switch (_inData["~"]) {
        case "ping":
          _outData["~"] = "pong";
          print("pong");
          break;
        case "dbquery":
          f = _connectToDb()
              .then((_) => _queryDb(_inData["query"]));
          print("dbquery");
          break;
        default:
          _response.statusCode = HttpStatus.notAcceptable;
          print("invalid data received: '${_inData["~"]}'");
      }
    } else {
      _response.statusCode = HttpStatus.notAcceptable;
    }
    return f;
  }

  Future _connectToDb() {
    _db =
        new PostgreSQLConnection(
            "localhost",
            5432,
            "postgres",
            username: "dlzp_client",
            password: "temppass");
    return _db.open();
  }

  Future _queryDb(String query) {
    return _db.query(query).then((List<List<dynamic>> results) {
      print(results);
      _outData["queryResult"] = results;
    });
      //      "SELECT numofpoints FROM test_table WHERE id = @id",
      //      substitutionValues: {"id": 3});
  }

  Future _closeRequest() {
    if(_outData != null) {
      _response.write(jsonEncode(_outData));
    }
    return _response.close()
        .then((_) => _db?.close())
        .then((_) {
          _inData = null;
          _outData = null;
        });
  }
}






