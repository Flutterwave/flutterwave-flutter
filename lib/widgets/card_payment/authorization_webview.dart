import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterwave/utils/flutterwave_urls.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthorizationWebview extends StatefulWidget {
  final String _url;
  final String _redirectUrl;

  AuthorizationWebview(this._url, this._redirectUrl);

  @override
  _AuthorizationWebviewState createState() => _AuthorizationWebviewState();
}

class _AuthorizationWebviewState extends State<AuthorizationWebview> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
          child: WebView(
            initialUrl: this.widget._url,
            javascriptMode: JavascriptMode.unrestricted,
            onPageStarted: this._pageStarted,
          ),
        ),
      ),
    );
  }

  void _pageStarted(String url) {
    // ignore: unnecessary_null_comparison
    final redirectUrl =
        // ignore: unnecessary_null_comparison
        (this.widget._redirectUrl == null || this.widget._redirectUrl.isEmpty)
            ? FlutterwaveURLS.DEFAULT_REDIRECT_URL
            : this.widget._redirectUrl;

    final bool startsWithMyRedirectUrl =
        url.toString().indexOf(redirectUrl.toString()) == 0;

    if (url != this.widget._url && startsWithMyRedirectUrl) {
      this._onValidationSuccessful(url);
      return;
    }
  }

  void _handleCardRedirectRequest(final String response) {
    final String responseString = Uri.decodeFull(response);
    final Map data = json.decode(responseString);
    if (data["status"] != null && data["status"] == "successful") {
      final String flwRef = data["flwRef"];
      Navigator.pop(this.context, flwRef);
    } else {
      final String errorMessage = data["message"] != null
          ? data["message"]
          : "Unable to complete transaction";
      Navigator.pop(this.context, {"error": errorMessage});
    }
    return;
  }

  void _handleMobileMoneyRedirectRequest(String response) {
    final String responseString = Uri.decodeFull(response);
    final Map map = json.decode(responseString);
    if (map["status"] == "success") {
      final String flwRef = map["data"]["flwRef"];
      Navigator.pop(this.context, flwRef);
      return;
    }
    Navigator.pop(this.context, {"error": map["message"]});
    return;
  }

  void _onValidationSuccessful(String url) {
    var response = Uri.dataFromString(url).queryParameters["response"];
    var resp = Uri.dataFromString(url).queryParameters["resp"];
    if (response != null) {
      return this._handleCardRedirectRequest(response);
    }
    if (resp != null) {
      return this._handleMobileMoneyRedirectRequest(resp);
    }
    return Navigator.pop(
        this.context, {"error": "Unable to process transaction"});
  }
}
