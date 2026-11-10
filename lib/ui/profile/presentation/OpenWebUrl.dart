import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenWebUrl extends StatefulWidget {
  final String webUrl;
  final String title;

  const OpenWebUrl({
    super.key,
    required this.webUrl,
    required this.title,
  });

  @override
  State<OpenWebUrl> createState() => _OpenWebUrlState();
}

class _OpenWebUrlState extends State<OpenWebUrl> {
  late final WebViewController controller;

  bool isLoading = true;
  int progress = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int value) {
            if (mounted) {
              setState(() {
                progress = value;
              });
            }
          },

          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },

          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },

          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'WebView Error: ${error.description}',
            );
          },

          onNavigationRequest: (NavigationRequest request) {
            debugPrint(
              'Navigating to: ${request.url}',
            );

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.webUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Stack(
        children: [
          WebViewWidget(
            controller: controller,
          ),

// Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

// Top progress bar
          if (isLoading && progress < 100)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress > 0
                    ? progress / 100
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
