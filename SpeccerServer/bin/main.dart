import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:pedantic/pedantic.dart';
import 'package:postgres/postgres.dart';
import 'package:dbcrypt/dbcrypt.dart';

const PORT = 58524;
const HOST = "dlzpserver.noip.me";
const CROSS_ORIGIN_ACCESS = "https://dlzpserver.noip.me";

const utf8Codec = Utf8Codec();
final uuidGen = new Uuid();
final dbcrypt = new DBCrypt();
final secureRandom = new Random.secure();

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
      response.headers.add("Access-Control-Allow-Origin", request.headers.value("origin"));
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
    _outData = new Map<String, dynamic>();
    _getClientDataString()
        .then((String stringData) => _inData = new Map<String, dynamic>.from(jsonDecode(stringData)))
        .then((_) => _parseClientInfo())
        .then((_) => _closeRequest())
        .catchError(_errorAttemptResponse)
        .then((_) => _closeRequest());
  }

  Future _closeRequest() {
    if(_outData != null) {
      _response.write(jsonEncode(_outData));
    }
    return _response.flush()
        .then((_) => _response.close())
        .then((_) => _db?.close())
        .then((_) {
      _inData = null;
      _outData = null;
    }).catchError((_){});
  }

  void _errorAttemptResponse(Object e) {
    try {
      _outData["error_object"] = e;
      _response
        ..statusCode = (_response.statusCode == HttpStatus.ok ? HttpStatus.internalServerError : _response.statusCode)
        ..write(_outData);
    } catch (e2) {}
    print("Error occurred - attempting response with: $e");
  }

  Future<String> _getClientDataString() {
    return _request.transform(utf8Codec.decoder).join().catchError((e) {
      return Future.error("Error joining client data");
    });
  }

  Future _parseClientInfo() {
    Future f = new Future((){});
    if (_inData.containsKey("~")) {
      _response.statusCode = HttpStatus.ok;
      _outData["~"] = _inData["~"];

      switch (_inData["~"]) {
        case "ping":
          _outData["~"] = "pong";
          print("pong");
          break;
//        case "dbquery":
//          f = _connectToDb()
//              .then((_) => _queryDb(_inData["query"]));
//          print("dbquery");
//          break;
        case "adduser":
          f = _connectToDb()
              .then((_) => _generateNewUuid(1))
              .then((String uuid) => _addUser(uuid, _inData["username"], _inData["password"]));
          print("adduser ${_inData["username"]}");
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





  Future<String> _generateNewUuid(int type) {
    String uuid = uuidGen.v4();
    return _db.query(
        "INSERT INTO identifier VALUES ('@uuid', @type);",
        substitutionValues: {
          "uuid": uuid,
          "type": type
        }).then((_) {
      return uuid;
    });
  }

  String _generateSalt() {
    StringBuffer sb = new StringBuffer();
    for(int i = 0; i < 8; i++) {
      sb.writeCharCode(secureRandom.nextInt(255));
    }

    if(sb.length != 8) {
      print("Error! Generated salt has an invalid length!");
    }

    return sb.toString();
  }

  Future _addUser(String uid, String username, String password) {
    if(password.length < 8) {
      return Future.error("Password not long enough.");
    } else {
      String salt = _generateSalt();
      String hash = dbcrypt.hashpw(password + salt, dbcrypt.gensalt());
      return _db.query(
          "INSERT INTO users VALUES (@uid, @name, @passhash @date_join @salt",
          substitutionValues: {
            "uid": uid,
            "name": username,
            "passhash": hash,
            "date_join": DateTime.now().toIso8601String(),
            "salt": salt
          }).then((_) => _outData["uid"] = uid);
    }
  }
  
//  Future _queryDb(String query) {
//    return _db.query(query).then((List<List<dynamic>> results) {
//      print(results);
//      _outData["queryResult"] = results;
//    });
//      //      "SELECT numofpoints FROM test_table WHERE id = @id",
//      //      substitutionValues: {"id": 3});
//  }
}






