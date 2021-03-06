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
  }
}

class Request {


  HttpRequest _request;
  HttpResponse _response;

  /// Response that is sent back to the user.
  /// Note: this is generally WRITE ONLY.
  Map<String, dynamic> _outData;

  /// Database connection.
  /// Null until [_connectToDb] is called (for each Request).
  PostgreSQLConnection _db;

  Request(HttpRequest request) {
    _request = request;
    _response = request.response;
    _outData = new Map<String, dynamic>();
    _getClientDataString()
        .then((String stringData) => Map<String, dynamic>.from(jsonDecode(stringData)))
        .then((Map<String, dynamic> inData) =>
            _parseClientInfo(inData)
            .catchError(_errorAttemptResponse))
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

  void _errorAttemptResponse(Object e, Object s) {
    print(e);
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
        _outData[DataElements.postgres_detail] = e.detail;
        _outData[DataElements.postgres_tableName] = e.tableName;

        if(!_outData.containsKey(ERROR_CODE)) {
          // If we haven't defined the error code, we don't know the error.
          _outData[ERROR_CODE] = ErrorCodes.UnknownPostgresError;

          // Mark this as not implemented, because we need to implement handling
          // this error, even if its a simple error code set.
          _response.statusCode = HttpStatus.notImplemented;
          _outData[DataElements.error_stacktrace] = s.toString();
        } else if (_response.statusCode >= HttpStatus.internalServerError) {
          _outData[DataElements.error_stacktrace] = s.toString();
        }
      } else {
        if(!_outData.containsKey(ERROR_CODE)) {
          // If we haven't defined the error code, we don't know the error.
          _outData[ERROR_CODE] = ErrorCodes.UnknownError;

          // Mark this as not implemented, because we need to implement handling
          // this error, even if its a simple error code set.
          _response.statusCode = HttpStatus.notImplemented;
          _outData[DataElements.error_stacktrace] = s.toString();
        } else if (_response.statusCode >= HttpStatus.internalServerError) {
          _outData[DataElements.error_stacktrace] = s.toString();
        }
      }
      _outData[DataElements.error_object] = e.toString();
    } catch (e2) {
      print(e2);
    }
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
      print(inData[DataElements.cmd]);

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
              .then((_) => _generateNewUuid(IdentifierTypes.User))
              .then((String uuid) =>
                  _addUser(
                      uuid,
                      inData[DataElements.username],
                      inData[DataElements.password],
                      inData[DataElements.email]
                  )
              );
          break;

        case RequestCodes.createProject:
          f = _connectToDb()
              .then((_) => Future.wait([
                _authenticateUser(inData[DataElements.username], inData[DataElements.password]),
                _generateNewUuid(IdentifierTypes.Project)
              ]))
              .then((List<String> ids) => _createProject(ids[0], ids[1], inData[DataElements.isPublic]));
          break;

        case RequestCodes.browseProjects:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _browseProjects(uid)
//                  .then((_) => _getRolesForUser(uid))
              );
          break;

        case RequestCodes.componentGetAll:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) => _userIsObserver(uid, inData[DataElements.pid]))
              .then((_) => _componentGetAll(inData[DataElements.pid]));
          break;

        case RequestCodes.componentGetRecent:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) => _userIsObserver(uid, inData[DataElements.pid]))
              .then((_) => _componentGetRecent(inData[DataElements.pid]));
          break;

        case RequestCodes.componentAdd:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _userIsContributer(uid, inData[DataElements.pid])
                  .then((_) =>
                      _componentAdd(
                         inData[DataElements.cid], // cid
                         inData[DataElements.pid],
                         uid, // uid
                         inData[DataElements.componentType],
                         inData[DataElements.componentData]
                      )
                  )
              )
              .then((_) => _componentGetRecent(inData[DataElements.pid]));
          break;

        case RequestCodes.commentGetAll:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _userCanInteractComment(uid, inData[DataElements.targetId])
                  .then((_) => _commentGetAll(inData[DataElements.targetId]))
              );
          break;

        case RequestCodes.commentAdd:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _userCanInteractComment(uid, inData[DataElements.targetId])
                  .then((_) => _generateNewUuid(IdentifierTypes.Comment))
                  .then((String newId) => _commentAdd(uid, newId, inData[DataElements.targetId], inData[DataElements.commentValue]))
              );
          break;

        case RequestCodes.roleSet:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _userIsOwner(uid, inData[DataElements.pid])
                  .then((_) => _getUidFromUsername(inData[DataElements.targetUsername]))
                  .then((String targetUid) =>
                      _roleSet(
                          uid,
                          targetUid,
                          inData[DataElements.pid],
                          inData[DataElements.roleCanView],
                          inData[DataElements.roleCanContribute],
                          inData[DataElements.roleCanManage]
                      )
                  )
                  .then((_) => _getAllRolesForPid(inData[DataElements.pid]))
              );
          break;

        case RequestCodes.roleGetAll:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) => _userIsObserver(uid, inData[DataElements.pid]))
              .then((_) => _getAllRolesForPid(inData[DataElements.pid]));
          break;

        case RequestCodes.setProjectPublicity:
          f = _connectToDb()
              .then((_) => _authenticateUser(inData[DataElements.username], inData[DataElements.password]))
              .then((String uid) =>
                  _userIsOwner(uid, inData[DataElements.pid])
                  .then((_) => _changeProjectPublicity(inData[DataElements.pid], inData[DataElements.isPublic]))
//                  .then((_) => _browseProjects(uid))
              );
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
  // Only return 400 level errors for rogue clients - people trying to do things
  // that they aren't allowed to do. If these are reached in development, the
  // client needs to be changed to prevent them from doing this.
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

  void _markOut400Error(String code) {
    _outData[ERROR_CODE] = code;
    _response.statusCode = HttpStatus.badRequest;
  }

  /// Initializes [_db] for this Request.
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

  /// Returns a new uuid.
  Future<String> _generateNewUuid(int type) {
    String uuid = uuidGen.v4();
    return _db.query(
        "INSERT INTO public.identifier VALUES (@uuid , @type)",
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

  /// Inserts new user to DB.
  /// Adds [uid] to outData.
  /// Returns [uid].
  Future<String> _addUser(String uid, String username, String password, String email) {
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
          }).then((_) => _outData[DataElements.uid] = uid)  // Also returns uid.
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

  /// Authenticates user from DB.
  /// Adds [uid] to outData.
  /// Returns [uid].
  Future<String> _authenticateUser(String username, String password) {
    if(username == null && password == null) {
      return Future<String>(() => "00000000-0000-0000-0000-000000000000");
    } else {
      return
        _db.query(
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
                    _outData[DataElements.uid] = uid;
                    return uid;
                  }
                }
              }
            });
    }
  }

  /// Gets a uid for a given username from DB.
  Future<String> _getUidFromUsername(String username) {
    return _db.query(
        "select u.uid from public.user as u where u.name = @name",
        substitutionValues: {
          "name": username
        }).then((List<List<dynamic>> query) {
          if(query.length != 1) {
            _markOut500Error(ErrorCodes.InvalidDatabaseStructure);
            throw "No query items received when at least one column should be returned.";
          } else if (query.first.isEmpty) {
            _markOut200Error(ErrorCodes.NoUserFound);
            throw "Could not find a user by that name.";
          } else if (query.first.length > 1) {
            _markOut500Error(ErrorCodes.MultipleUsersFound);
            throw "Too many users match that name.";
          } else {
            return query.first.first;
          }
        });
  }

  /// Inserts new project to DB.
  /// Inserts [uid] as creator of pid to DB.
  /// Adds [pid] to outData.
  Future _createProject(String uid, String pid, bool public) {
    if(public == null) {
      _markOut400Error(ErrorCodes.InvalidRequestArguments);
      throw "Public specifier not provided when creating project.";
    } else {
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
                  }
              ).catchError((e) {
                if(e is PostgreSQLException) {
                  if(e.columnName == "uid") {
                    _markOut200Error(ErrorCodes.InvalidUidForNewProject);
                  }
                }
                throw e;
              })
      ).then((_) => _outData[DataElements.pid] = pid);
    }
  }

  Future _getAllRolesForPid(String pid) {
    return
      _db.query(
          "select r.uid, r.pid, r.is_owner, r.is_developer, u.name from public.role as r "
          "inner join public.user as u "
          "on u.uid = r.uid "
          "where r.pid = @pid",
          substitutionValues: {
            "pid": pid
          }
      ).then((List<List<dynamic>> data) {
        _outData[DataElements.roles] = data;
      });
  }

  /// Gets all projects readable by [uid] from DB.
  /// Adds projects to outData.
  /// Adds project name components to outData.
  Future _browseProjects(String uid) {
    return Future(
        () =>
            // Get all public projects
            // Get all private projects where uid is a developer (owners are considered developers)
            _db.query(
                "select ppg.pid, ppg.is_public, rrg.is_owner, rrg.is_developer, c.data from public.component as c "
                "inner join ( "
                "  select max(cc.revision), cc.cid from public.component as cc "
                "  where cc.type = @nametype group by cc.cid "
                ") ccg "
                "on ccg.max = c.revision and ccg.cid = c.cid "
                "full join ( "
                "  select distinct pp.pid, pp.is_public from public.project as pp "
                "  inner join public.role as rr "
                "  on pp.pid = rr.pid  "
                "  where ( pp.is_public or rr.uid = @uid ) "
                ") ppg "
                "on ppg.pid = c.pid "
                "left join public.role as rrg "
                "on rrg.pid = ppg.pid and rrg.uid = @uid "
                "where ppg.pid is not null",
                substitutionValues: {
                  "nametype": 1,
                  "uid": uid
                }
            )
    ).then((List<List<dynamic>> data) {
      _outData[DataElements.projectsAndRoles] = data;
    });
  }
//
//  Future _getRolesForUser(String uid) {
//    return
//      _db.query(
//          "select r.pid, r.is_owner, r.is_developer from public.role as r "
//          "where r.uid = @uid",
//          substitutionValues: {
//            "uid": uid
//          }
//      ).then((List<List<dynamic>> data) {
//        _outData[DataElements.roles] = data;
//      });
//  }

  /// Verifies [uid] has legitimate roles to view [pid] from DB.
  /// Throws error if not allowed.
  Future _userIsObserver(String uid, String pid) {
    return
      _db.query(
          "select distinct p.pid from public.project as p "
          "inner join public.role as r "
          "on p.pid = r.pid "
          "where ( p.pid = @pid ) "
          "and ( p.is_public or ( r.uid = @uid ) ) ",
          substitutionValues: {
            "pid": pid,
            "uid": uid
          }
      ).then((List<List<dynamic>> data) {
        if(data.isEmpty || data[0].isEmpty) {
          _markOut400Error(ErrorCodes.OperationNotAuthorized);
          throw "User is not an observer of this project.";
        }
      });
  }

  /// Verifies [uid] has legitimate roles to contribute to [pid] from DB.
  /// Throws error if not allowed.
  Future _userIsContributer(String uid, String pid) {
    return
      _db.query(
          "select distinct p.pid from public.project as p "
          "inner join public.role as r "
          "on p.pid = r.pid "
          "where ( p.pid = @pid ) "
          "and ( r.uid = @uid and r.is_developer ) ",
          substitutionValues: {
            "pid": pid,
            "uid": uid
          }
      ).then((List<List<dynamic>> data) {
        if(data.isEmpty || data[0].isEmpty) {
          _markOut400Error(ErrorCodes.OperationNotAuthorized);
          throw "User is not a contributer of this project.";
        }
      });
  }

  /// Verifies [uid] has legitimate roles to manage [pid] from DB.
  /// Throws error if not allowed.
  Future _userIsOwner(String uid, String pid) {
    return
      _db.query(
          "select distinct p.pid from public.project as p "
          "inner join public.role as r "
          "on p.pid = r.pid "
          "where ( p.pid = @pid ) "
          "and ( r.uid = @uid and r.is_owner ) ",
          substitutionValues: {
            "pid": pid,
            "uid": uid
          }
      ).then((List<List<dynamic>> data) {
        if(data.isEmpty || data[0].isEmpty) {
          _markOut400Error(ErrorCodes.OperationNotAuthorized);
          throw "User is not an owner of this project.";
        }
      });
  }

  /// Gets all components of [pid] from DB.
  /// Adds components to outData.
  Future _componentGetAll(String pid) {
    return
      _db.query(
          "select c.cid, c.revision, c.pid, c.uid, c.date_created, c.type, c.data from public.component as c "
          "where c.pid = @pid",
          substitutionValues: {
            "pid": pid
          }
      ).then((List<List<dynamic>> data) {
        data.forEach((List<dynamic> row) {
          row[4] = (row[4] as DateTime).toIso8601String();
        });
        _outData[DataElements.components] = data;
      });
  }
  /*

  select c.cid, c.revision, c.pid, c.uid, c.date_created, c.type, c.data from public.component as c
inner join (select max(cc.revision), cc.cid from public.component as cc group by cc.cid) ccg
on ccg.max = c.revision and ccg.cid = c.cid

   */

  /// Gets all recent components of [pid] from DB.
  /// Adds components to outData.
  Future _componentGetRecent(String pid) {
    return
      _db.query(
          "select c.cid, c.revision, c.pid, c.uid, c.date_created, c.type, c.data from public.component as c "
          "inner join (select max(cc.revision), cc.cid from public.component as cc where cc.pid = @pid group by cc.cid) ccg "
          "on ccg.max = c.revision and ccg.cid = c.cid",
          substitutionValues: {
            "pid": pid
          }
      ).then((List<List<dynamic>> data) {
        data.forEach((List<dynamic> row) {
          row[4] = (row[4] as DateTime).toIso8601String();
        });
        _outData[DataElements.components] = data;
      });
  }

  /// Inserts component data by [uid] to [pid] of [componentType] with [data] and potential parent [cid] to DB.
  /// If [cid] doesn't refer to an existing parent component, a new uuid is generated for this component.
  /// Revision of this component is parent's + 1 or 1 (if no parent).
  Future _componentAdd(String potentialParentCid, String pid, String uid, int componentType, String jsonData) {
    int revision;
    return Future(() =>
        _db.query(
            "select max(c.revision) + 1 from public.component as c "
            "where c.cid = @cid",
            substitutionValues: {
              "cid": potentialParentCid
            }
        )
    ).then((List<List<dynamic>> results) {
      if(results.isEmpty || results.first.isEmpty) {
        _markOut500Error(ErrorCodes.InvalidDatabaseStructure);
        throw "No component element found";
      } else if(results.first.first == null || results.first.first.toString().toLowerCase() == "null") {
        revision = 1;
        return _generateNewUuid(IdentifierTypes.Component);
      } else {
        revision = results.first.first;
        return potentialParentCid;
      }
    }).then((Object cid) =>
        _db.query(
            "insert into public.component "
            "values ( @cid, @revision, @pid, @uid, @date_created, @type, @data )",
            substitutionValues: {
              "cid": cid,
              "revision": revision,
              "pid": pid,
              "uid": uid,
              "date_created": DateTime.now().toIso8601String(),
              "type": componentType,
              "data": jsonData
          }
    ));
  }

  Future _commentGetAll(String id_target) {
    return Future(
        () =>
            _db.query(
                "select o.value, o.date_created, o.uid from public.comment as o "
                "where o.id_target = '@target'",
                substitutionValues: {
                  "target": id_target
                }
            )
    ).then((List<List<dynamic>> data) => _outData[DataElements.comments] = data);
  }

  Future _commentAdd(String uid, String new_id, String target_id, String value) {
    return
      _db.query(
          "insert into public.comment values (@id, @uid, @target, @date, @value)",
          substitutionValues: {
            "id": new_id,
            "uid": uid,
            "target": target_id,
            "date": DateTime.now().toIso8601String(),
            "value": value
          }
      );
  }

  /// Verifies whether [uid] can comment on [target_id].
  /// Throws error if not allowed.
  Future _userCanInteractComment(String uid, String target_id) {
    return
      _db.query(
          "select i.type from public.identifier as i "
          "where i.id = @target_id",
          substitutionValues: {
            "target_id": target_id
          }
      ).then((List<List<dynamic>> data) {
        if(data.isEmpty || data[0].isEmpty) {
          _markOut400Error(ErrorCodes.InvalidDatabaseStructure);
          throw "Could not find that target identifier in the database.";
        } else {
          switch(data.first.first) {
            case IdentifierTypes.User:
              // Can always comment on users (for now).
              return null;
              break;

            case IdentifierTypes.Project:
            case IdentifierTypes.Component:
              // Check if we can access this.
              return _userIsObserver(uid, target_id);
              break;

            case IdentifierTypes.Comment:
              // We will implement this later.
              _markOut500Error(ErrorCodes.NotImplemented);
              throw "Commenting on comments is not yet implemented.";
//                    _commentAdd(uid, new_id, target_id, value);
              break;

            default:
              _markOut400Error(ErrorCodes.IdentifierNotFound);
              throw "Identifier found in database is not known.";
              break;
          }
        }
      });
  }

  Future _roleSet(String uid, String targetId, String pid, bool canView, bool canContribute, bool canManage) {
    if(uid == targetId) {
      _markOut500Error(ErrorCodes.NotImplemented);
      throw "Setting one's own roles is not implemented.";
    } else if (!canView && (canContribute || canManage)) {
      _markOut400Error(ErrorCodes.InvalidRequestArguments);
      throw "Cannot set contribute nor manage flag if view flag is set to false.";
    } else {
      if(canView) {
        return
          _db.query(
              "insert into public.role values (@uid, @pid, @owner, @developer) "
              "on conflict on constraint role_pkey "
              "do update set is_owner = @owner, is_developer = @developer",
              substitutionValues: {
                "uid": targetId,
                "pid": pid,
                "owner": canManage,
                "developer": canContribute
              }
          );
      } else {
        return
          _db.query(
              "delete from public.role "
              "where public.role.uid = @uid "
              "and public.role.pid = @pid",
              substitutionValues: {
                "uid": targetId,
                "pid": pid
              }
          );
      }
    }
  }

  Future _changeProjectPublicity(String pid, bool isPublic) {
    return
      _db.query(
          "update public.project set is_public = @isPublic where pid = @pid",
          substitutionValues: {
            "isPublic": isPublic,
            "pid": pid
          }
      );
  }
}






