
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';
import '../Structures/Role.dart';
import '../Structures/Project.dart';

class RequestBrowseProjects extends AbstractRequest {
  RequestBrowseProjects(String username, String password) : super(RequestCodes.browseProjects) {
    if(username != null && password != null) {
      addUserAuthData(username, password);
    }
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.receivedUpdatedProjects(data[DataElements.projectsAndRoles]);
        break;
      default:
        throw "Error browsing projects from server: ${data[ERROR_CODE]}";
    }
  }
}