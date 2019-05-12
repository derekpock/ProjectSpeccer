
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';
import '../Structures/Project.dart';

class RequestChangeProjectPublicity extends AbstractRequest {
  Project _project;
  bool _isPublic;
  RequestChangeProjectPublicity(String username, String password, this._project, this._isPublic) :
        super(RequestCodes.setProjectPublicity) {
    addUserAuthData(username, password);
    outData[DataElements.pid] = _project.getPid();
    outData[DataElements.isPublic] = _isPublic;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.updatedProject(_project.getPid(), _isPublic, _project.getName());
        break;
      default:
        throw "Error changing project publicity on server: ${data[ERROR_CODE]}";
    }
  }
}