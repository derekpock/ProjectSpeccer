
import 'DBClient.dart';
import 'Structures/Component.dart';
import 'UIPage.dart';
import 'Structures/Project.dart';
import 'Structures/Role.dart';

abstract class UIManagerInteractionInterface {
  void setActivePage(UIPage page);
  DBClient getDBClient();

  void refreshProjectsAndRoles();
  void userLoggedIn(String username, String password, String uid);
  String getAuthUsername();
  String getAuthPassword();
  String getUid();
  void pongReceived();
  void newPasswordInvalid();
  void usernameTaken();
  void userLoggedOut();
  void badLogin();
  void newProjectCreated(Project p);
  void receivedUpdatedProjects(List<dynamic> rawProjects);
  void openProject(String pid);
  void addNavigation(String url);

  void updatedProject(String pid, bool isPublic, String name);
  void receivedComponents(String pid, List<List<Component>> components);
  void receivedProjectRoles(String pid, List<Role> roles);

  void receivedSetRoleFailed();
  void authenticationError();
}