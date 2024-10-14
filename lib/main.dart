import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "https://www.google.co.in";
  final urlController = TextEditingController();
  List<String> bookMarksList = [];

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: await webViewController?.getUrl()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: "Enter URL or Search Query",
                ),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var newUrl = Uri.parse(value);
                  if (newUrl.scheme.isEmpty) {
                    newUrl =
                        Uri.parse("https://www.google.com/search?q=$value");
                  }
                  webViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: WebUri.uri(newUrl)),
                  );
                },
              ),
            ),
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri.uri(Uri.parse(url)),
                ),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
              ),
            ),
            // _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}
