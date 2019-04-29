
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
        List<dynamic> rawProjects = data[DataElements.projects];
        List<dynamic> rawRoles = data[DataElements.roles];

        List<Project> projects = new List();
        Map<String, Role> roles = new Map();

        rawProjects.forEach((dynamic projInfo) {
          projInfo = projInfo as List<dynamic>;
          projects.add(new Project(projInfo[0], projInfo[1]));
        });

        rawRoles.forEach((dynamic roleInfo) {
          roleInfo = roleInfo as List<dynamic>;
          roles[roleInfo[0]] = new Role(roleInfo[0], roleInfo[1], roleInfo[2]);
        });

        uimii.receivedUpdatedProjects(projects, roles);

        break;
      default:
        throw "Error browsing projects from server: ${data[ERROR_CODE]}";
    }
  }
}