
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';

class RequestLogin extends AbstractRequest {

  String _username;
  String _password;

  RequestLogin(String username, String password) :
        _username = username,
        _password = password,
        super(RequestCodes.auth) {
    addUserAuthData(username, password);
  }

  @override
  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.userLoggedIn(_username, _password);
        break;
      case ErrorCodes.WrongAuth:
        uimii.userLoggedOut();
        uimii.badLogin();
        break;
      default:
        throw "Error pinging server: ${data[ERROR_CODE]}";
    }
  }
}