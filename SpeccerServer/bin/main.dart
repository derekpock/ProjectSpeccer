import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:postgres/postgres.dart';
import 'package:dbcrypt/dbcrypt.dart';

import 'SharedStatics.dart';

const PORT = 58524;
const HOST = "dlzpserver.noip.me";
const CROSS_ORIGIN_ACCESS = "https://dlzpserver.noip.me";

const utf8Codec = Utf8Codec();
final uuidGen = new Uuid();
final dbcrypt = new DBCrypt();
final secureRandom = new Random.secure();

String dbClientUsername;
String dbClientPassword;
String coaop; // crossOriginAccessOverridePassword

void main(List<String> arguments) async {
  print("Server started at ${DateTime.now().toString()}");

  File privateConfigFile = new File("config.json");
  try {
    Map<String, dynamic> config = jsonDecode(privateConfigFile.readAsStringSync());
    dbClientUsername = config["dbClientUsername"];
    dbClientPassword = config["dbClientPassword"];
    coaop = config["crossOriginAccessOverridePassword"];  // Must not be empty or null to be active.
    if(coaop != null && coaop.isEmpty) {
      coaop = null;
    }

    if(dbClientUsername.isEmpty || dbClientPassword.isEmpty) {
      print("Invalid configuration file: ${privateConfigFile.path}");
      print("Aborting: One of the required configruation items is not available.");
      exit(2);
    }
  } catch (e) {
    print("Server unable to read config file: ${privateConfigFile.path}");
    print("Aborting: Is ${Directory.current} the correct working directory?");
    exit(1);
  }

  List<InternetAddress> serverIps = await InternetAddress.lookup(HOST);
  print("Accepting connections from ${CROSS_ORIGIN_ACCESS} or any address from ${serverIps}.");

  SecurityContext serverContext = SecurityContext();
  serverContext.useCertificateChain("/etc/apache2/ssl.crt/fullchain.pem");
  serverContext.usePrivateKey("/etc/apache2/ssl.key/key.pem");

  HttpServer server = await HttpServer.bindSecure(InternetAddress.anyIPv4, PORT, serverContext);

  await for (HttpRequest request in server) {
    // Get request information.
    HttpResponse response = request.response;
    bool setRequest = request.method == "POST";

    // Set cross origin access.
    // Only requests from our host or from our address are allowed.
    //
    // There's another backdoor where if the data contains a "coaop" element
    // with a correct password (found in config.json), then it will also be
    // cross origin allowed.
    if (serverIps.contains(request.connectionInfo.remoteAddress)) {
      response.headers.set("Access-Control-Allow-Origin", request.headers.value("origin"));
    } else {
      response.headers.set("Access-Control-Allow-Origin", CROSS_ORIGIN_ACCESS);
    }

    ////////////////////////////////////////////////////////////////////////////
    // Starting here, user communication may be invalid.
    // We may return 500 or 400 errors.
    ////////////////////////////////////////////////////////////////////////////

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
      print("Unsupported request: ${request.method}.");
    }
    print("Waiting for next request...");
  }
}

class Request {

  HttpRequest _request;
  HttpResponse _response;
  Map<String, dynamic> _outData;
  PostgreSQLConnection _db;

  Request(HttpRequest request) {
    _request = request;
    _response = request.response;
    _outData = new Map<String, dynamic>();
    _getClientDataString()
        .then((String stringData) => Map<String, dynamic>.from(jsonDecode(stringData)))
        .then((Map<String, dynamic> inData) => _parseClientInfo(inData))
        .then((_) => _closeRequest())
        .catchError(_errorAttemptResponse)
        .then((_) => _closeRequest())
        .catchError((e) {
          print("Error in attempt to respond after error. Hands are off: $e");
        });
  }

  Future _closeRequest() {
    if(_outData != null) {
      if(!_outData.containsKey(ERROR_CODE)) {
        // If we have no error, let the client know we did good.
        _outData[ERROR_CODE] = ErrorCodes.SoFarSoGood;
      }
      _response.write(jsonEncode(_outData));
      _outData = null;
    }
    return _response.flush()
        .then((_) => _response.close())
        .then((_) => _db?.close())
        .catchError((_){});
  }

  void _errorAttemptResponse(Object e) {
    try {
      if(e is PostgreSQLException) {
//        _outData["columnName"] = e.columnName;
//        _outData["dataTypeName"] = e.dataTypeName;
//        _outData["fileName"] = e.fileName;
//        _outData["hint"] = e.hint;
//        _outData["message"] = e.message;
//        _outData["routineName"] = e.routineName;
//        _outData["schemaName"] = e.schemaName;
//        _outData["trace"] = e.trace;
        _outData[DataElements.postgres_error] = true;
        _outData[DataElements.postgres_code] = e.code;
        _outData[DataElements.postgres_constraintName] = e.constraintName;
        _outData[DataElements.postgres_detail] = e.detail.replaceAll("\"", "'");
        _outData[DataElements.postgres_tableName] = e.tableName;

        if(!_outData.containsKey(ERROR_CODE)) {
          // If we haven't defined the error code, we don't know the error.
          _outData[ERROR_CODE] = ErrorCodes.UnknownPostgresError;

          // Mark this as not implemented, because we need to implement handling
          // this error, even if its a simple error code set.
          _response.statusCode = HttpStatus.notImplemented;
        }
      } else {
        if(!_outData.containsKey(ERROR_CODE)) {
          // If we haven't defined the error code, we don't know the error.
          _outData[ERROR_CODE] = ErrorCodes.UnknownError;

          // Mark this as not implemented, because we need to implement handling
          // this error, even if its a simple error code set.
          _response.statusCode = HttpStatus.notImplemented;
        }
      }
      _outData[DataElements.error_object] = e.toString();
    } catch (e2) {}
    print("Error occurred - attempting response with: $_outData");
  }

  Future<String> _getClientDataString() {
    return _request.transform(utf8Codec.decoder).join().catchError((e) {
      _outData[ERROR_CODE] = ErrorCodes.InvalidRequestFormat;
      _response.statusCode = HttpStatus.preconditionFailed;
      return Future.error("Error joining client data");
    });
  }

  Future _parseClientInfo(Map<String, dynamic> inData) {
    Future f = new Future((){});

    // Check our development backdoor.
    // Client must provide the correct password for this to work.
    if(coaop != null && inData["coaop"] == coaop) {
      _response.headers.set("Access-Control-Allow-Origin", _request.headers.value("origin"));
    }

    if(inData.containsKey(DataElements.cmd)) {
      _response.statusCode = HttpStatus.ok;
      _outData[DataElements.cmd] = inData[DataElements.cmd];

      // Within each case (non-default), only return 200 with error information.
      switch (inData[DataElements.cmd]) {

        case RequestCodes.ping:
          _outData[DataElements.cmd] = "pong";
          print("pong");
          break;

        case RequestCodes.auth:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]));
          break;

        case RequestCodes.addUser:
          f = _connectToDb()
              .then((_) => _generateNewUuid(1))
              .then((String uuid) => _addUser(uuid, inData[DataElements.username], inData[DataElements.password], inData[DataElements.email]));
          print("adduser ${inData[DataElements.username]}");
          break;

        case RequestCodes.createProject:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) => [uid, _generateNewUuid(2)])
              .then((List<Object> args) => _createProject(args[1], args[0], inData[DataElements.isPublic]))
              .then((String pid) {
                _outData[DataElements.pid] = pid;
              });
          break;

        default:
          _response.statusCode = HttpStatus.notFound;
          _outData[ERROR_CODE] = ErrorCodes.UnknownRequestCode;
          print("Invalid request code received: '${inData[DataElements.cmd]}'");
      }
    } else {
      _response.statusCode = HttpStatus.notAcceptable;
      _outData[ERROR_CODE] = ErrorCodes.InvalidRequest;
    }
    return f;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Beyond this point, each of these functions are used within valid cases.
  //
  // Only return 500 level errors for real server issues, such as unable to
  // connect to the database or other _unexpected_ exceptions.
  //
  // Otherwise, return 200 level and provide any errors using internally
  // managed [ErrorCodes]. We don't want to throw red errors to the browser
  // if the user forgets their password, etc.
  //
  // Must put an error code into [_outData] via ERROR_CODE if we expect and know
  // the error, otherwise it will throw a notImplemented error.
  //////////////////////////////////////////////////////////////////////////////

  void _markOut200Error(String code) {
    _outData[ERROR_CODE] = code;
  }

  void _markOut500Error(String code) {
    _outData[ERROR_CODE] = code;
    _response.statusCode = HttpStatus.internalServerError;
  }

  Future _connectToDb() {
    _db =
        new PostgreSQLConnection(
            "localhost",
            5432,
            "postgres",
            username: dbClientUsername,
            password: dbClientPassword);
    return _db.open().catchError((e) {
      if(e is PostgreSQLException) {
        _outData[ERROR_CODE] = ErrorCodes.DBAuthFailure;
        _response.statusCode = HttpStatus.serviceUnavailable;
      }
      return Future.error(e);
    });
  }

  Future<String> _generateNewUuid(int type) {
    String uuid = uuidGen.v4();
    return _db.query(
        "INSERT INTO public.identifier VALUES (@uuid , @type);",
        substitutionValues: {
          "uuid": uuid,
          "type": type
        }).then((_) {
          return uuid;
        }).catchError((e) {
          if(e is PostgreSQLException) {
            _markOut500Error(ErrorCodes.UuidGenerationFailure);
          }
          throw e;
        });
  }

  String _generateSalt() {
    StringBuffer sb = new StringBuffer();
    for(int i = 0; i < 8; i++) {
      sb.writeCharCode(secureRandom.nextInt(255));
    }
    return sb.toString();
  }

  Future _addUser(String uid, String username, String password, String email) {
    if(password.length < 8) {
      _outData[ERROR_CODE] = ErrorCodes.InvalidNewPassword;
      return Future.error("Password not long enough.");
    } else {
      return _db.query(
          "INSERT INTO public.user VALUES (@uid, @name, @passhash, @date_join, @email)",
          substitutionValues: {
            "uid": uid,
            "name": username,
            "passhash": dbcrypt.hashpw(password, dbcrypt.gensalt()),
            "date_join": DateTime.now().toIso8601String(),
            "email": email
          }).then((_) => _outData["uid"] = uid)
          .catchError((e) {
            if(e is PostgreSQLException) {
              if(e.constraintName == "user_name_key") {
                _markOut200Error(ErrorCodes.UsernameTaken);
              }
            }
            throw e;
          });
    }
  }

  Future<String> _authenticateUser(String username, String password) {
    return _db.query(
        "SELECT passhash, uid FROM public.user WHERE name = @username",
        substitutionValues: {
          "username": username
        }).then((List<List<dynamic>> query) {
          if(query.length > 1) {
            _markOut500Error(ErrorCodes.MultipleUsersFound);
            throw "Multiple query items received from auth.";
          } else if (query.isEmpty) {
            _markOut200Error(ErrorCodes.WrongAuth);
            throw "Wrong username or password.";
          } else {
            if(query.first.length != 2) {
              _markOut500Error(ErrorCodes.InvalidDatabaseStructure);
              throw "Needed 2 items from from db in auth!";
            } else {
              String passhash = query.first[0];
              String uid = query.first[1];
              if(!dbcrypt.checkpw(password, passhash)) {
                _markOut200Error(ErrorCodes.WrongAuth);
                throw "Wrong username or password.";
              } else {
                return uid;
              }
            }
          }
        });
  }

  Future<String> _createProject(String pid, String uid, bool public) {
    return Future(
            () =>
                _db.query(
                    "INSERT INTO public.project VALUES (@pid, @public, @date)",
                    substitutionValues: {
                      "pid": pid,
                      "public": public,
                      "date": DateTime.now().toIso8601String()
                    }
                ).catchError((e) {
                  if(e is PostgreSQLException) {
                    _markOut500Error(ErrorCodes.ProjectCreationFailure);
                  }
                  throw e;
                })
    ).then(
            (_) =>
                _db.query(
                    "INSERT INTO public.role VALUES (@uid, @pid, @is_owner, @is_developer)",
                    substitutionValues: {
                      "uid": uid,
                      "pid": pid,
                      "is_owner": true,
                      "is_developer": true
                    })
                .catchError((e) {
                  if(e is PostgreSQLException) {
                    if(e.columnName == "uid") {
                      _markOut200Error(ErrorCodes.InvalidUidForNewProject);
                    }
                  }
                  throw e;
                })
    ).then((_) => pid);
  }
}






