import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scr_amenities/screens/MapsWebview.dart';
import 'package:scr_amenities/screens/amenities_list.dart';
import 'package:scr_amenities/screens/home.dart';
import 'package:scr_amenities/screens/porter_list.dart';
import 'package:scr_amenities/screens/splash_screen.dart';
import 'package:scr_amenities/screens/taxi_list.dart';
import './screens/select_stn.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'Station App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => Splash(),
        '/SelectStn': (context) => SelectStn(),
        '/Home': (context) => Home(
            selectedStation:
                ModalRoute.of(context)!.settings.arguments as String),
        '/AmenitiesList': (context) => AmenitiesList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/PorterList': (context) => PorterList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/TaxiList': (context) => TaxiList(
              stnName: ModalRoute.of(context)!.settings.arguments as String,
              amenityType: ModalRoute.of(context)!.settings.arguments as String,
            ),
        '/WebView': (context) => MapsWebview(
            geturl: ModalRoute.of(context)!.settings.arguments as String),
          
      },
    );
  }
}
