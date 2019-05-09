
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../Structures/Component.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestGetComponents extends AbstractRequest {
  String _pid;

  /// Username and password can be null to request components of a public
  /// project.
  RequestGetComponents(String username, String password, this._pid) :
        super(RequestCodes.componentGetAll) {
    addUserAuthData(username, password);
    outData[DataElements.pid] = _pid;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.receivedComponents(_pid, Component.parseComponentsFromRawQuery(data[DataElements.components]));
        break;
      default:
        throw "Error getting components from server: ${data[ERROR_CODE]}";
    }
  }
}