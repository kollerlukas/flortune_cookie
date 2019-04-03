import 'dart:collection';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flortune_cookie/fortune_cookie_loader.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlortuneCookieApp());

class FlortuneCookieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Flortune Cookie',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: _FortuneCookiePage());
}

class _FortuneCookiePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FortuneCookieState();
}

class _FortuneCookieState extends State<_FortuneCookiePage> {
  /// load new fortunes
  final _loader = FortuneCookieLoader();

  /// controls for flare animation
  final _controller = MyFlareControls();

  @override
  void dispose() {
    super.dispose();
    // close loading stream
    _loader.close();
  }

  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(
        title: Text(
          'Flortune Cookie',
          style: TextStyle(color: Colors.red[900].withAlpha(150)),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.red[200],
      body: StreamBuilder(
          stream: _loader.stream,
          initialData: '',
          builder: (context, snapshot) => Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // animated cookie
                    _buildCookie(),
                    // fortune card
                    _buildFortune(snapshot.data),
                    // add button
                    _buildButton()
                  ]))));

  _buildCookie() => Expanded(
      child: FlareActor('assets/fortune_cookie.flr', controller: _controller));

  _buildFortune(fortune) => Flexible(
      child: Card(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(fortune,
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold)))));

  _buildButton() => Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: RaisedButton(
              color: Colors.amber[300],
              textColor: Colors.deepOrange[900].withAlpha(100),
              onPressed: () {
                // load new fortune
                _loader.loadFortuneCookie();
                // play cookie animation
                _controller.enqueue('reset');
                _controller.enqueue('break_cookie');
              },
              child: const Text('NEW FORTUNE!',
                  style: TextStyle(fontWeight: FontWeight.bold)))));
}

/// Extends [FlareControls] to add the ability to enqueue animations.
class MyFlareControls extends FlareControls {
  final Queue<String> _queue = Queue();
  bool _animPlaying = false;

  enqueue(anim) {
    if (_animPlaying) {
      _queue.add(anim);
    } else {
      play(anim);
    }
  }

  @override
  void onCompleted(String name) {
    _animPlaying = false;
    if (_queue.isNotEmpty) {
      play(_queue.removeFirst());
    }
  }

  @override
  void play(String name) {
    _animPlaying = true;
    super.play(name);
  }
}
