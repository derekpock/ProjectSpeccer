import 'dart:html';
import 'dart:convert';

class Request {
  static const _PORT = 58524;

//  static const _ADDRESS = "dlzpserver.noip.me";
//  static const _URL = "https://${ADDRESS}:${PORT}/";
  static const _ADDRESS = "localhost";
  static const _URL = "http://${_ADDRESS}:${_PORT}/";
  static const utf8Codec = Utf8Codec();

  HttpRequest _request;
  Map<String, dynamic> _data;
  Map<String, dynamic> _response;

  Request(Map<String, dynamic> data) {
    assert(data != null);
    _data = data;

    try {
      _request = new HttpRequest();
      _request.onReadyStateChange.listen(_onData);
      _request.onError.listen(_onError);
      _request.open("POST", _URL, async: true);
      _request.send(jsonEncode(_data));
      print("sent: ${data}");
    } catch (e) {
      print("exception during send: $e");
      _request = null;
    }
  }

  Map<String, dynamic> GetResponse() {
    return _response;
  }

  void _onData(_) {
    bool requestReady =
        (_request != null && _request.readyState == HttpRequest.DONE);
    if (requestReady) {
      if(_request.status == HttpStatus.ok) {
        _response = jsonDecode(_request.response);
        print("recieved: ${_response}");
      } else {
        print("error received: ${_request.status}");
      }
    }
  }

  void _onError(_) {
    print("error mid-request: ${_request.readyState} ${_request.status}");
  }
}
