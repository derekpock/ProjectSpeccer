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
    if(request.abort) {
      return;
    }
    request.outData["coaop"] = coaop;
    JsonHttpRequest
        .makeRequest(request.outData)
        .then((inData) {
          if(request.abort) {
            return;
          }
          String apiErrorCode = inData[ERROR_CODE];
          int httpErrorCode = inData[JsonHttpRequest.jsonHttpRequestStatus];

          switch(httpErrorCode) {
            case HttpStatus.ok:
              request.dataReceived(inData, _uimii);
              break;

            case HttpStatus.badRequest:
              switch(apiErrorCode) {
                case ErrorCodes.OperationNotAuthorized:
                  _uimii.authenticationError();
                  break;
                default:
                  throw "A manageable bad request was made to the server: $apiErrorCode";
                  break;
              }
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
        .catchError((Object error, Object stacktrace) {
          return Future<Null>.error("An error occurred when making a request to the server. Request: ${request.outData[DataElements.cmd]} Details below:\n${error}", stacktrace);
        }); // SO this
  }
}
