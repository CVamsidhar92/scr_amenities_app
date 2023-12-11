// Import necessary packages and screens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scr_amenities/screens/MapsWebview.dart';
import 'package:scr_amenities/screens/amenities_list.dart';
import 'package:scr_amenities/screens/home.dart';
import 'package:scr_amenities/screens/porter_list.dart';
import 'package:scr_amenities/screens/splash_screen.dart';
import 'package:scr_amenities/screens/taxi_list.dart';
import './screens/select_stn.dart';

// Main function to run the Flutter application
void main() {
  runApp(MyApp());
}

// Define the main application widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set system overlay style for the status bar
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    // Build and configure the MaterialApp
    return MaterialApp(
      title: 'Station App',
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color swatch
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash', // Set the initial route to the splash screen
      routes: {
        // Define named routes with corresponding screen widgets
        '/splash': (context) => Splash(), // Splash screen route
        '/SelectStn': (context) => SelectStn(), // Select station screen route
        '/Home': (context) => Home(
            selectedStation:
                ModalRoute.of(context)!.settings.arguments as String), // Home screen route
        '/AmenitiesList': (context) => AmenitiesList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ), // Amenities list screen route
        '/PorterList': (context) => PorterList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ), // Porter list screen route
        '/TaxiList': (context) => TaxiList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ), // Taxi list screen route
        '/WebView': (context) => MapsWebview(
            geturl: ModalRoute.of(context)!.settings.arguments as String), // Webview screen route
      },
    );
  }
}
