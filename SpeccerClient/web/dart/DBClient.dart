import 'dart:html';
import 'dart:convert';
import 'dart:async';

typedef void RequestResponseDelegate(Map<String, dynamic> data);

class Request {
  static const _PORT = 58524;
  static const _ADDRESS = "https://dlzpserver.noip.me";
  static const _URL = "${_ADDRESS}:${_PORT}";

  static Future<Map<String, dynamic>> makeRequest(
      Map<String, dynamic> inputData) {
    Completer<Map<String, dynamic>> completer = new Completer();
    new Request(inputData, completer.complete);
    return completer.future;
  }

  HttpRequest _request;
  Map<String, dynamic> _data;
  Map<String, dynamic> _response;
  RequestResponseDelegate _callback;

  Request(Map<String, dynamic> data, RequestResponseDelegate callback) {
    assert(data != null);
    _data = data;
    _callback = callback;

    try {
      _request = new HttpRequest();
      _request.onReadyStateChange.listen(_onData);
      _request.onError.listen(_onError);
      _request.open("POST", _URL, async: true);
      _request.send(jsonEncode(_data));
      print("Sent $data to $_URL");
    } catch (e) {
      print("Exception during send operation: $e");
      _request = null;
    }
  }

  void _onData(_) {
    bool requestReady =
        (_request != null && _request.readyState == HttpRequest.DONE);
    if (requestReady) {
      if (_request.status == HttpStatus.ok) {
        _response = jsonDecode(_request.response);
        print("Received: ${_response}");
        if (_callback != null) {
          _callback(_response);
        }
      } else {
        print("Error received: ${_request.status} with ${_request.response}");
      }
    }
  }

  void _onError(_) {
    print("Error mid-request: ${_request.readyState} ${_request.status}");
  }
}
