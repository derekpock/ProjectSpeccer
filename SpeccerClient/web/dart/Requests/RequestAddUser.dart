
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';


class RequestAddUser extends AbstractRequest {
  String _username;
  String _password;

  RequestAddUser(String username, String password, String email) :
        _username = username,
        _password = password,
        super(RequestCodes.addUser) {
    addUserAuthData(username, password);
    outData[DataElements.email] = email;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.userLoggedIn(_username, _password, data[DataElements.uid]);
        break;
      case ErrorCodes.InvalidNewPassword:
        uimii.newPasswordInvalid();
        break;
      case ErrorCodes.UsernameTaken:
        uimii.usernameTaken();
        break;
      default:
        throw "Error adding new user to server: ${data[ERROR_CODE]}";
    }
  }
}