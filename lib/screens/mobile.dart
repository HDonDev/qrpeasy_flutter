import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:qrpeasy_flutter/core/env/env.dart';
import 'package:qrpeasy_flutter/widgets/mobile_error.dart';
import 'package:qrpeasy_flutter/widgets/mobile_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MobileView extends StatefulWidget {
  const MobileView({super.key});

  @override
  _MobileViewState createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  final WebViewController _webViewController = WebViewController();

  final _loadingProgress = Signal<double>(0.0);
  final _currentPageTitle = Signal<String>("Login");
  final _isPageNotAvailable = Signal<bool>(false);
  late Resource<String> titleResourse;

  // TODO: This needs refactoring & error handling.
  Future<void> _postFCMToken(String url) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final bool? didPostToken = sharedPreferences.getBool('post-fcm-token');
    if (url != "https://qrpeasy.com/login" && didPostToken != true) {
      try {
        final String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          throw "Token was not found";
        }

        final uri = Uri.https('qrpeasy.com', '/api/fcm-token', {'fcm_token': fcmToken});
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode != 200) {
          print("[Debug] Request: ${response.request}");
          throw Exception("Status code error - Status code: ${response.statusCode}");
        }

        await sharedPreferences.setBool("post-fcm-token", true);
        print("[Debug] Token is sent");
      } catch (e) {
        print("[Debug] Error: $e");
        rethrow;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    titleResourse = Resource<String>(fetcher: _getPageTitle, source: _currentPageTitle);

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            titleResourse.set(const ResourceReady("يرجى الإنتظار..."));
            _loadingProgress.set(progress / 100);
          },
          onPageStarted: (String url) async {
            await _postFCMToken(url);
          },
          onPageFinished: (String url) => titleResourse.refresh(),
          onHttpError: (HttpResponseError error) {
            if (kDebugMode) {
              print("An Http Error Occured: ${error.response?.statusCode}");
            }
            if (kDebugMode) {
              print("An Http Error Occured: ${error.request?.uri}");
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print("A Web Resourse Error Occured: ${error.errorType}");
            }
            if (kDebugMode) {
              print("A Web Resourse Error Occured: ${error.errorCode}");
            }
            if (kDebugMode) {
              print("A Web Resourse Error Occured: ${error.description}");
            }

            _isPageNotAvailable.set(true);
          },
          onHttpAuthRequest: (request) => print("The request is $request"),
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.startsWith(Env.appUrl)) {
              return NavigationDecision.prevent;
            }
            if (request.url.contains('register')) _webViewController.goBack();
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(Env.appUrl))
      ..clearCache()
      ..reload();
  }

  Future<String> _getPageTitle() async {
    final title = await _webViewController.getTitle();
    return title?.substring(10 + 1) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: ResourceBuilder(
          resource: titleResourse,
          builder: (context, resourceState) {
            String title = resourceState.map(
              ready: (ready) => ready.value,
              error: (error) => "Page 404",
              loading: (loading) => "Loading",
            );
            return Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SignalBuilder(
          signal: _loadingProgress,
          child: WebViewWidget(controller: _webViewController),
          builder: (context, value, child) {
            (bool isFinishedLoading, bool isPageNotAvailable) state = (value > 0.7, _isPageNotAvailable.value);
            return switch (state) {
              (true, false) => child ?? const SizedBox.shrink(),
              (false, true) => MobileError(onRefreshButtonPressed: _refreshButton),
              (true, true) => MobileError(onRefreshButtonPressed: _refreshButton),
              (_, _) => const MobileLoading(),
            };
          },
        ),
      ),
    );
  }

  void _refreshButton() {
    _webViewController.reload();
    _isPageNotAvailable.set(false);
  }
}
