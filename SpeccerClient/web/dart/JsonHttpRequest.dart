
import 'dart:html';
import 'dart:async';
import 'dart:convert';
import 'dart:js';

class JsonHttpRequest {
  static const jsonHttpRequestStatus = "jsonHttpRequestStatus";

  static const _PORT = 58524;
  static const _ADDRESS = "https://dlzpserver.noip.me";
  static const _URL = "${_ADDRESS}:${_PORT}";

  /// Make a request to the server, sending a [Map<String, dynamic>] as the
  /// outData to the server and receiving back a [Map<String, dynamic>] as the
  /// inData from the server some time later.
  ///
  /// Future returned once the entire inData has been received.
  ///
  /// Will add a "jsonHttpRequestStatus":??? element to the returned server's
  /// response representing the success of the operation where ??? is the
  /// [HttpStatus] code returned from the operation.
  ///
  /// Future will return an error if the server's response is not a valid json
  /// decodeable string, or if there was an error communicating with the server.
  static Future<Map<String, dynamic>> makeRequest(Map<String, dynamic> outData) {
    Completer<Map<String, dynamic>> completer = new Completer();
    new JsonHttpRequest(outData, completer);
    return completer.future;
  }

  HttpRequest _request;
  Completer _completer;

  /// Used internally by [makeRequest].
  JsonHttpRequest(Map<String, dynamic> data, Completer<Map<String, dynamic>> completer) {
    assert(data != null);
    _completer = completer;

    try {
      _request = new HttpRequest();
      _request.onReadyStateChange.listen(_onData);
      _request.onError.listen(_onError);
      _request.open("POST", _URL, async: true);
      _request.send(jsonEncode(data));
      dprint("Sent $data to $_URL");
    } catch (e) {
      dprint("Exception during send operation: $e");
      _completer?.completeError("Exception during send operation: $e");
      _completer = null;
      _request = null;
    }
  }

  void _onData(_) {
    bool requestReady = (_request != null && _request.readyState == HttpRequest.DONE);
    if (requestReady) {
      Map<String, dynamic> inData;
      try {
        inData = jsonDecode(_request.response);
        inData[jsonHttpRequestStatus] = _request.status;
        if (_request.status == HttpStatus.ok) {
          dprint("Received: ${inData}");
          _completer?.complete(inData);
        } else {
          dprint("Error received: status ${_request.status} with response ${_request.response}");
          _completer?.complete(inData);
        }
      } catch (e) {
        dprint("Error parsing received: status ${_request.status} with response ${_request.response} and error $e");
        _completer?.completeError("Invalid json response from server: status ${_request.status} with response ${_request.response} and error $e");
      } finally {
        _request = null;
        _completer = null;
      }
    }
  }

  void _onError(_) {
    dprint("Error mid-request: status ${_request.status} with response ${_request.response}");
    _completer?.completeError("Error mid request: status ${_request.status} with response ${_request.response}");
    _completer = null;
    _request = null;
  }
  
  void dprint(Object object) {
    if(context["debug"]) {
      print(object);
    }
  }
}
