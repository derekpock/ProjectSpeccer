
import '../AbstractRequest.dart';
import '../SharedStatics.dart';
import '../UIManagerInteractionInterface.dart';
import 'dart:html';

class RequestPing extends AbstractRequest {
  RequestPing() : super(RequestCodes.ping);

  void dataReceived(Map<String, dynamic> data, UIManagerInteractionInterface uimii) {
    switch(data[ERROR_CODE]) {
      case ErrorCodes.SoFarSoGood:
        uimii.pongReceived();
        break;
      default:
        throw "Error pinging server: ${data[ERROR_CODE]}";
    }
  }
}