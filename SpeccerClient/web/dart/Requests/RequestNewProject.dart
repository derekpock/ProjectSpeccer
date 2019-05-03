
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';
import '../Structures/Project.dart';

class RequestNewProject extends AbstractRequest {
  bool _isPublic;

  RequestNewProject(String username, String password, this._isPublic) : super(RequestCodes.createProject) {
    addUserAuthData(username, password);
    outData[DataElements.isPublic] = _isPublic;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.newProjectCreated(new Project(data[DataElements.pid], _isPublic));
        break;
      default:
        throw "Error creating new project on server: ${data[ERROR_CODE]}";
    }
  }
}