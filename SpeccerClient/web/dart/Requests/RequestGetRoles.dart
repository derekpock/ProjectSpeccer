
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../Structures/Role.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestGetRoles extends AbstractRequest {
  String _pid;
  RequestGetRoles(String username, String password, this._pid) :
        super(RequestCodes.roleGetAll) {
    addUserAuthData(username, password);
    outData[DataElements.pid] = _pid;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.receivedProjectRoles(_pid, Role.parseRolesFromRawQuery(data[DataElements.roles]));
        break;
      default:
        throw "Error getting roles for project from server: ${data[ERROR_CODE]}";
    }
  }
}