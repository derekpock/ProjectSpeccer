
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestChangeProjectPublicity extends AbstractRequest {
  String _pid;
  bool _isPublic;
  RequestChangeProjectPublicity(String username, String password, this._pid, this._isPublic) :
        super(RequestCodes.setProjectPublicity) {
    addUserAuthData(username, password);
    outData[DataElements.pid] = _pid;
    outData[DataElements.isPublic] = _isPublic;
  }

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.updatedProjectPublicity(_pid, _isPublic);
        break;
      default:
        throw "Error changing project publicity on server: ${data[ERROR_CODE]}";
    }
  }
}