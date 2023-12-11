import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// Creating a stateful widget for the MapsWebview
class MapsWebview extends StatefulWidget {
  final String geturl;

  // Constructor to receive the URL for the WebView
  MapsWebview({required this.geturl});

  @override
  _MapsWebviewState createState() => _MapsWebviewState();
}

// State class for the MapsWebview widget
class _MapsWebviewState extends State<MapsWebview> {
  // Variable to track loading state of the WebView
  bool loading = true;

  // WebViewController for controlling the WebView
  late WebViewController _webViewController;

  // Initialization method when the state is created
  @override
  void initState() {
    super.initState();
    // Fetch the current device location when the widget is initialized
    _getCurrentLocation();
  }

  // Method to fetch the current device location using Geolocator
  Future<void> _getCurrentLocation() async {
    try {
      // Getting the current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      // Printing the latitude and longitude of the current position
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
    } catch (e) {
      // Handling errors if there is an issue with fetching the location
      print('Error: $e');
    }
  }

  // Method to handle navigation requests in the WebView
  void _handleNavigationRequest(NavigationRequest request) async {
    // Check if the URL starts with 'google.navigation:q=' (Google Maps navigation)
    if (request.url.startsWith('google.navigation:q=')) {
      // Open Google Maps in a separate app
      if (await canLaunch(request.url)) {
        await launch(request.url);
      } else {
        throw 'Could not launch Google Maps.';
      }
    } else {
      // Load the URL in the WebView if it's not a Google Maps navigation request
      _webViewController.loadUrl(request.url);
    }
  }

  // Build method defining the UI of the MapsWebview widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // WebView widget for displaying the map
          WebView(
            initialUrl: widget.geturl,
            javascriptMode: JavascriptMode.unrestricted,
            // Callback when the page finishes loading
            onPageFinished: (value) {
              setState(() {
                loading = false;
              });
            },
            // Callback when the WebView is created
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            // Callback to handle navigation requests
            navigationDelegate: (NavigationRequest request) {
              // Handle the navigation request and prevent default navigation
              _handleNavigationRequest(request);
              return NavigationDecision.prevent;
            },
          ),
          // Display a loading spinner while the WebView is loading
          if (loading)
            Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ),
        ],
      ),
    );
  }
}
