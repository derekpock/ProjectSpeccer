import 'SharedStatics.dart';
import 'UIManagerInteractionInterface.dart';

abstract class AbstractRequest {

  void addUserAuthData(String username, String password) {
    outData[DataElements.username] = username;
    outData[DataElements.password] = password;
  }

  Map<String, dynamic> outData;

  AbstractRequest(String cmd) :
        outData = new Map() {
    outData[DataElements.cmd] = cmd;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii);
}