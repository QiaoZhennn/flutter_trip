import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const Set<String> CATCH_URLS = {'m.ctrip.com/', 'm.ctrip.com/html5/', 'm.ctrip.com/html5', 'https://m.ctrip.com/html5/'};

class WebView extends StatefulWidget {
  final String url;
  final String statusBarColor;
  final String title;
  final bool hideAppBar;
  final bool backForbid;

  const WebView(
      {Key key,
      this.url,
      this.statusBarColor,
      this.title,
      this.hideAppBar,
      this.backForbid = false})
      : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final webViewReference = FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  bool exiting = false;

  @override
  void initState() {
    super.initState();
    webViewReference.close();
    _onUrlChanged = webViewReference.onUrlChanged.listen((String event) {});
    _onStateChanged =
        webViewReference.onStateChanged.listen((WebViewStateChanged event) {
      switch (event.type) {
        case WebViewState.startLoad:
          if (_isToMain(event.url) && !exiting) {
            if (widget.backForbid) {
              // forbid to return main html5 page of ctrip.
              // just launch current page
              webViewReference.launch(widget.url);
            } else {
              Navigator.pop(context);
              exiting = true;
            }
          }
          break;
        default:
          break;
      }
    });
    _onHttpError =
        webViewReference.onHttpError.listen((WebViewHttpError event) {
      print(event);
    });
  }

  bool _isToMain(String url) {
    if (null == url) return false;
    if (CATCH_URLS.contains(url)) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    webViewReference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusBarColorStr = widget.statusBarColor ?? 'ffffff';
    Color backButtonColor;
    if (statusBarColorStr == 'ffffff') {
      backButtonColor = Colors.black;
    } else {
      backButtonColor = Colors.white;
    }
    print(widget.url);
    return Scaffold(
      body: Column(children: <Widget>[
        _appBar(Color(int.parse('0xff' + statusBarColorStr)), backButtonColor),
        Expanded(
            child: WebviewScaffold(
          url: widget.url,
          withZoom: true,
          withLocalStorage: true,
          hidden: true,
          initialChild: Container(
            color: Colors.white,
            child: Center(
              child: Text('Waiting...'),
            ),
          ),
        ))
      ]),
    );
  }

  _appBar(Color backgroundColor, Color backButtonColor) {
    if (widget.hideAppBar ?? false) {
      return Container(
        color: backgroundColor,
        height: 30,
      );
    }
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(0, 30, 0, 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // to return previous page
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.close,
                  color: backButtonColor,
                  size: 26,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  widget.title ?? '',
                  style: TextStyle(color: backButtonColor, fontSize: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
