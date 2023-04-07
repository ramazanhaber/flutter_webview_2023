import 'dart:io';

import 'package:flutter/material.dart';
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
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.roketnot.com/'));
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
                if (_currentPosition - _startPosition > 50) {
                  if (await controller.canGoBack()) {
                    controller.goBack();
                  }
                }
                setState(() {
                  _currentPosition = 0.0;
                  _startPosition = 0.0;
                });
              },
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
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



