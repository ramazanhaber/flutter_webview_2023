import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  late WebViewController controller;
  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller =
        WebViewController.fromPlatformCreationParams(params);
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            if (url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }else if (url.startsWith('whatsapp://send')) {
              _launchUrl(url);
              return NavigationDecision.prevent;
            } else if (url.startsWith('tel:')) {
              _launchUrl(url);
              return NavigationDecision.prevent;
            } else if (url.startsWith('mailto:')) {
              _launchUrl(url);
              return NavigationDecision.prevent;
            } else if (url.startsWith('https://www.facebook.com/')) {
              return NavigationDecision.navigate;
            } else if (url.startsWith('https://twitter.com/')) {
              return NavigationDecision.navigate;
            } else if (url.startsWith('https://www.instagram.com/')) {
              return NavigationDecision.navigate;
            } else {
              return NavigationDecision.navigate;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.trendyol.com/'));
  }

  late double _currentPosition = 0.0;
  late double _startPosition = 0.0;

  Future<bool> _onBack() async {
    var value = await controller.canGoBack();
    if (value) {
      controller.goBack();
      return false;
    } else {
      exit(0);
    }
  }

  int sensitivity=100;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:   WillPopScope(
        onWillPop: _onBack,
        child: Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onHorizontalDragStart: (details) {
                _startPosition = details.localPosition.dx;
                print(_startPosition);
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _currentPosition = details.localPosition.dx;
                  print(_currentPosition);

                });
              },
              onHorizontalDragEnd: (details) async {
                if (_currentPosition - _startPosition > sensitivity) {
                  _onBack();
                } else if (_currentPosition - _startPosition < -sensitivity) {
                  if (await controller.canGoForward()) {
                    controller.goForward();
                  }
                } else {
                  // Sayfayı kaydırma işlemi
                  print(_currentPosition.toString()+"!!");


                }
                setState(() {
                  _currentPosition = 0.0;
                  _startPosition = 0.0;
                });
              },
              child: Stack(
                children: [
                  WebViewWidget(controller: controller
                    , gestureRecognizers: Set()
                      ..add(Factory<VerticalDragGestureRecognizer>(
                              () => VerticalDragGestureRecognizer())),
                  ),
                  Positioned(
                    left: _currentPosition - 50.0,
                    top: 50.0,
                    child: Opacity(
                      opacity: (_currentPosition - _startPosition)==0?1:50 / 50.0,
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

