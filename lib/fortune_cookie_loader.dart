import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Helper class that Loads a fortune cookie from Api (http://yerkee.com/api).
class FortuneCookieLoader {
  final _streamController = StreamController<String>();

  get stream => _streamController.stream;

  close() => _streamController.close();

  /// Asynchronously loads a fortune from the api. The return type is a String.
  loadFortuneCookie() async {
    _streamController.add(''); // indicate loading
    // setup http request
    HttpClient()
        .getUrl(Uri.parse('http://yerkee.com/api/fortune'))
        // wait for a response
        .then((r) => r.close())
        // decode json from response
        .then((r) => r.transform(utf8.decoder).join())
        // retrieve fortune and add to stream
        .then((d) => _streamController.add(jsonDecode(d)['fortune']));
  }
}
