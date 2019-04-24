import 'dart:html';
import 'AbstractRequest.dart';
import 'SharedStatics.dart';
import 'UIManagerInteractionInterface.dart';
import 'config.dart';
import 'JsonHttpRequest.dart';

class DBClient {
  UIManagerInteractionInterface _uimii;
  DBClient();

  void setUimii(UIManagerInteractionInterface uimii) {
    _uimii = uimii;
  }

  void makeRequest(AbstractRequest request) {
    request.outData["coaop"] = coaop;
    JsonHttpRequest
        .makeRequest(request.outData)
        .then((inData) {
          String apiErrorCode = inData[ERROR_CODE];
          int httpErrorCode = inData[JsonHttpRequest.jsonHttpRequestStatus];

          switch(httpErrorCode) {
            case HttpStatus.ok:
              request.dataReceived(inData, _uimii);
              break;

            case HttpStatus.methodNotAllowed:
              throw "Invalid request sent to server: $apiErrorCode";
              break;
            case HttpStatus.notImplemented:
              throw "An operation exception on server has not yet been implemented: $apiErrorCode";
              break;
            case HttpStatus.preconditionFailed:
              throw "Request was ill-formatted: $apiErrorCode";
              break;
            case HttpStatus.notFound:
              throw "The send request command has not yet been implemented on the server: $apiErrorCode";
              break;
            case HttpStatus.notAcceptable:
              throw "The send request did not include a request command: $apiErrorCode";
              break;
            case HttpStatus.internalServerError:
              throw "An internal server error occurred: $apiErrorCode";
              break;
            case HttpStatus.serviceUnavailable:
              throw "Server unable to contact database: $apiErrorCode";
              break;
            default:
              throw "Unknown http error code ($httpErrorCode) from server (dev should probably address this code): $apiErrorCode";
              break;
          }
        })
        .catchError((Object error) {
          throw "An error occurred when making a request to the server. Details below:\n${error}";
        });
  }

//  void addUser(String username, String password, String email) {
//    var data = _createUserAuthData(RequestCodes.addUser, username, password);
//    data[DataElements.email] = email;
//
//    JsonHttpRequest.makeRequest(data).then(_dataFromServer);
//  }
//
//  void login(String username, String password) {
//    JsonHttpRequest.makeRequest(_createUserAuthData(RequestCodes.auth, username, password)).then(_dataFromServer);
//  }
//
//  void createProject(String username, String password, bool isPublic) {
//    var data = _createUserAuthData(RequestCodes.createProject, username, password);
//    data[DataElements.isPublic] = isPublic;
//
//    JsonHttpRequest.makeRequest(data).then(_dataFromServer);
//  }
}
