import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebPage(),
    );
  }
}

class WebPage extends StatefulWidget {
  WebPage({Key? key}) : super(key: key);

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {

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
        mediaTypesRequiringUserAction: <PlaybackMediaTypes>{},
      );
    } else {
      params = PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params);
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {});
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            final isPDF = request.url.endsWith('.pdf');
            if (isPDF) {
              if (Platform.isAndroid) {
                if (await canLaunch(request.url)) {
                  await launch(
                    request.url,
                    forceSafariVC: false,
                    forceWebView: false,
                    headers: <String, String>{'header_key': 'header_value'},
                  );
                  return NavigationDecision.prevent;
                } else {
                  return NavigationDecision.navigate;
                }
              } else if (Platform.isIOS) {
                if (await canLaunch(request.url)) {
                  await launch(
                    request.url,
                    forceSafariVC: true,
                    headers: <String, String>{'header_key': 'header_value'},
                  );
                  return NavigationDecision.prevent;
                } else {
                  return NavigationDecision.navigate;
                }
              }else{
                return NavigationDecision.navigate;
              }
            }else if (url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            } else if (url.startsWith('whatsapp://send')) {
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
      ..loadRequest(Uri.parse(webLink));
  }

  String webLink ='https://roketnot.com/';
  // String webLink ='https://www.trendyol.com/';

  Future<bool> _onBack() async {
    var value = await controller.canGoBack();
    if (value) {
      controller.goBack();
      return false;
    } else {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }

     return false;
    }
  }

  Future<bool> _onForward() async {
    var value = await controller.canGoForward();
    if (value) {
      controller.goForward();
      return false;
    } else {
      return true;
    }
  }

  int sensitivity = 100;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: _onBack,
          child: Container(
            child: Stack(
              children: [
                WebViewWidget(
                  controller: controller,
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: Platform.isIOS ? backButton(): backButton(), // Android için SizeBox diyebilirsin kapanır
                ),
                Positioned(
                  bottom: 20,
                  left: 70,
                  child:Platform.isIOS ? nextButton():nextButton(),// Android için SizeBox diyebilirsin kapanır
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell nextButton() {
    return InkWell(
                  onTap: _onForward,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                );
  }

  InkWell backButton() {
    return InkWell(
                  onTap: _onBack,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                );
  }
}
