
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../Structures/Component.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestAddComponent extends AbstractRequest {
  String _pid;
  RequestAddComponent(String username, String password, Component component) :
        _pid = component.getPid(),
        super(RequestCodes.componentAdd) {
    addUserAuthData(username, password);
    if(!component.writeIfDirty(outData)) {
      print("A clean component was sent!");
    }
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.receivedComponents(_pid, Component.parseComponentsFromRawQuery(data[DataElements.components]));
        break;
      default:
        throw "Error sending component to server: ${data[ERROR_CODE]}";
    }
  }
}