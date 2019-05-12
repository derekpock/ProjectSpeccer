import 'SharedStatics.dart';
import 'UIManagerInteractionInterface.dart';

abstract class AbstractRequest {

  bool abort;

  void addUserAuthData(String username, String password) {
    if(username != null && password != null) {
      outData[DataElements.username] = username;
      outData[DataElements.password] = password;
    }
  }

  Map<String, dynamic> outData;

  AbstractRequest(String cmd) :
        outData = new Map(),
        abort = false {
    outData[DataElements.cmd] = cmd;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii);
}