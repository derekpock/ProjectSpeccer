
import 'DBClient.dart';
import 'UIPage.dart';

abstract class UIManagerInteractionInterface {
  void userLoggedIn(String username, String password);
  String getAuthUsername();
  String getAuthPassword();
  void pongReceived();
  void newPasswordInvalid();
  void usernameTaken();
  void userLoggedOut();
  void badLogin();

  void setActivePage(UIPage page);
  DBClient getDBClient();
}