
import 'DBClient.dart';
import 'UIPage.dart';
import 'Structures/Project.dart';
import 'Structures/Role.dart';

abstract class UIManagerInteractionInterface {
  void setActivePage(UIPage page);
  DBClient getDBClient();

  void refreshProjectsAndRoles();
  void userLoggedIn(String username, String password);
  String getAuthUsername();
  String getAuthPassword();
  void pongReceived();
  void newPasswordInvalid();
  void usernameTaken();
  void userLoggedOut();
  void badLogin();
  void newProjectCreated(Project p);
  void receivedUpdatedProjects(List<Project> projects, Map<String, Role> roles);
  void openProject(Project p);
  void addNavigation(String url);
}