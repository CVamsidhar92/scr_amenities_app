import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Define a StatefulWidget for the AdminWebview screen
class AdminWebview extends StatefulWidget {
  // Require a URL when creating an instance of AdminWebview
  final String url;

  AdminWebview({required this.url});

  @override
  _AdminWebviewState createState() => _AdminWebviewState();
}

// Define the state for the AdminWebview screen
class _AdminWebviewState extends State<AdminWebview> {
  // Declare a WebViewController to interact with the WebView
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    // Build the scaffold for the AdminWebview screen
    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(
        title: Text('Admin Login'), // Title of the app bar
        // Remove the back button from the app bar
        // automaticallyImplyLeading: false,
        // Actions in the app bar (Refresh button)
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload(); // Reload the WebView content
            },
          ),
        ],
      ),
      // Body of the screen
      body: WillPopScope(
        // Prevent the user from navigating back with the Android back button
        onWillPop: () async {
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack(); // If WebView can go back, navigate back
            return false; // Do not close the screen
          }
          return true; // Allow closing the screen if WebView cannot go back
        },
        child: WebView(
          // WebView widget to display web content
          initialUrl: widget.url, // Initial URL passed from the constructor
          javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController; // Store the controller
          },
          // Disable gesture recognizer (prevent swipe gestures)
          gestureNavigationEnabled: false,
        ),
      ),
    );
  }
}
