import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Webview extends StatefulWidget {
  final String animation;
  final String room;
  const Webview({Key? key, required this.animation, required this.room})
      : super(key: key);

  @override
  State<Webview> createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  String _animation = 'Base';
  WebViewController? _controller;
  Map<String, String> animationMap = {
    'Base': 'https://www.youtube.com/',
    'Sleep': 'https://gerardjm018.github.io/animationproto/sleep.html',
    'Workout': 'https://gerardjm018.github.io/animationproto/walkAction.html',
    'Study': ''
  };

  Map<String, String> roomMap = {};

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
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
      ..loadRequest(Uri.parse(animationMap[_animation]!));
    print(widget.animation);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, // Black border color
              width: 2.0, // Border width
            ),
          ),
          child: WebViewWidget(controller: _controller!),
          height: 300,
          width: 300,
        ),
        IconButton(
            onPressed: () {
              setState(() {
                _controller!.loadRequest(Uri.parse(
                    'https://gerardjm018.github.io/animationproto/sleep.html'));
              });
            },
            icon: Icon(Icons.add))
      ],
    );
  }
}
