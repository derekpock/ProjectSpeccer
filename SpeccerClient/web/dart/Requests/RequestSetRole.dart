
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../Structures/Role.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestSetRole extends AbstractRequest {
  String _pid;
  RequestSetRole(String username, String password, this._pid, String targetUser, bool canView, bool canContribute, bool canManage) : super(RequestCodes.roleSet) {
    addUserAuthData(username, password);
    outData[DataElements.pid] = _pid;
    outData[DataElements.targetUsername] = targetUser;
    outData[DataElements.roleCanView] = canView;
    outData[DataElements.roleCanContribute] = canContribute;
    outData[DataElements.roleCanManage] = canManage;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.receivedProjectRoles(_pid, Role.parseRolesFromRawQuery(data[DataElements.roles]));
        break;
      case ErrorCodes.NoUserFound:
        uimii.receivedProjectRoles(_pid, Role.parseRolesFromRawQuery(data[DataElements.roles]));
        uimii.receivedSetRoleFailed();
        break;
      default:
        throw "Error sending role set request to server: ${data[ERROR_CODE]}";
    }
  }
}