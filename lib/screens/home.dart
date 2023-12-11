// Importing necessary packages and files
import 'package:flutter/material.dart';
import 'package:scr_amenities/screens/amenities_list.dart';
import 'package:scr_amenities/screens/porterWebview.dart';
import 'package:scr_amenities/screens/tadWebview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scr_amenities/screens/base_url.dart';


// Defining the Home widget that extends StatefulWidget
class Home extends StatefulWidget {
  final String selectedStation;
  

  // Constructor to receive the selected station name
  const Home({Key? key, required this.selectedStation}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
  
}

// State class for the Home widget
class _HomeState extends State<Home> {
    // List to store data fetched from the API
  List<Map<String, dynamic>> dataa = [];

  // List of static data containing amenities information
  final List<Map<String, dynamic>> staticData = [
    {
      'id':'01',
      'title': 'ATVMs',
      'value': 'ATVMs',
      'image': 'assets/images/atvms.jpeg',
    },
    {
      'id':'02',
      'title': 'Booking Counter',
      'value': 'Booking Counter',
      'image': 'assets/images/booking.jpeg',
    },
    {
      'id':'03',
      'title': 'PRS Counter',
      'value': 'PRS Counter',
      'image': 'assets/images/prs.jpeg',
    },
    {
      'id':'04',
      'title': 'Parcel Office',
      'value': 'Parcel Office',
      'image': 'assets/images/pr.jpg',
    },
    {
      'id':'05',
      'title': 'Waiting Hall',
      'value': 'Waiting Hall',
      'image': 'assets/images/wh.jpeg',
    },
    {
      'id':'06',
      'title': 'Divyangjan Facility',
      'value': 'Divyangjan Facility',
      'image': 'assets/images/dv.jpg',
    },
    {
      'id':'07',
      'title': 'Parking',
      'value': 'Parking',
      'image': 'assets/images/parking.jpeg',
    },
    {
      'id':'08',
      'title': 'Out Gates',
      'value': 'Out Gates',
      'image': 'assets/images/outgate.jpeg',
    },
    {
      'id':'09',
      'title': 'Stair Case',
      'value': 'Stair Case',
      'image': 'assets/images/str.jpeg',
    },
    {
      'id':'10',
      'title': 'Escalator',
      'value': 'Escalator',
      'image': 'assets/images/esc.jpeg',
    },
    {
      'id':'11',
      'title': 'Lift',
      'value': 'Lift',
      'image': 'assets/images/lift.jpeg',
    },
    {
      'id':'12',
      'title': 'Cloak Rooms',
      'value': 'Cloak Rooms',
      'image': 'assets/images/cr.jpeg',
    },
      {
      'id':'13',
      'title': 'Multi Purpose Stall',
      'value': 'Multi Purpose Stall',
      'image': 'assets/images/mps.jpeg',
    },
       {
      'id':'14',
      'title': 'Help Desk',
      'value': 'Help Desk',
      'image': 'assets/images/helpdesk.jpeg',
    },
  
     {
      'id':'15',
      'title': '1 Station 1 Product',
      'value': 'One Station One Product',
      'image': 'assets/images/osop.jpeg',
    },
     
    {
      'id':'16',
      'title': 'Drinking Water',
      'value': 'Drinking Water',
      'image': 'assets/images/dw.jpeg',
    },
    {
       'id':'17',
      'title': 'Catering Stall',
      'value': 'Catering',
      'image': 'assets/images/catg.jpeg',
    },
    {
       'id':'18',
      'title': 'Train Arr/Dep',
      'value': 'TAD',
      'image': 'assets/images/trad.jpeg',
    },
      {
       'id':'19',
      'title': 'Retiring Room',
      'value': 'Retiring Room',
      'image': 'assets/images/rr.jpeg',
    },
    {
       'id':'20',
      'title': 'Bus Stop',
      'value': 'Bus Stop',
      'image': 'assets/images/bus.jpeg',
    },
    {
       'id':'21',
      'title': 'Restrooms',
      'value': 'Toilets',
      'image': 'assets/images/washrooms.jpg',
    },
    {
       'id':'22',
      'title': 'Medical',
      'value': 'Medical',
      'image': 'assets/images/medical.jpeg',
    },
    {
       'id':'23',
      'title': 'Taxi Stand',
      'value': 'Taxi Stand',
      'image': 'assets/images/taxi.jpeg',
    },
     {
       'id':'24',
      'title': 'Book Stall',
      'value': 'Book Stall',
      'image': 'assets/images/Book Stall.png',
    },
    {
       'id':'25',
      'title': 'Wheel Chair',
      'value': 'Wheel Chair',
      'image': 'assets/images/wheelchair.png',
    },
     {
       'id':'26',
      'title': 'Porter Information',
      'value': 'Porter',
      'image': 'assets/images/porter.jpeg',
    },
     {
       'id':'27',
      'title': 'ATM',
      'value': 'ATM',
      'image': 'assets/images/atm.png',
    },
     
  ];

  // Method to fetch data from the API
  Future<void> fetchData() async {
        // Constructing the API endpoint URL
    final String url = base_url + '/stnam';

    // Making a POST request to the API with station name as a parameter
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'StnName': widget.selectedStation,
      }),
    );

    // Handling the API response
    if (response.statusCode == 200) {
      print('API Response: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == 'ok') {
                // Parsing and updating the data if the API response is successful
        final List<dynamic> parsedData = responseData['data'];

        setState(() {
          dataa = List<Map<String, dynamic>>.from(parsedData);
        });
      } else {
                // Logging the API status if it is not 'ok'
        print('API Status: ${responseData['status']}');
      }
    } else {
            // Logging the API error if the response status code is not 200
      print('API Error: ${response.statusCode}');
      // Handle error
    }
  }

  // Method to fetch TAD (Train Arrival/Departure) data from the API
  Future<String> fetchtaddata() async {
        // Constructing the TAD API endpoint URL
    final String url = base_url + '/gettadurl';
    final body = {'station': widget.selectedStation, 'amenityType': 'TAD'};

    try {
            // Making a POST request to the TAD API
      final response = await http.post(Uri.parse(url), body: body);
            // Handling the TAD API response
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          final firstMap = jsonData[0] as Map<String, dynamic>;
          final url = firstMap['url'] as String?;
          if (url != null && url.isNotEmpty) {
     // Returning the TAD URL if available in the response
            return url;
          } else {
            throw Exception('URL not found in the API response');
          }
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      return ''; // Return a default value when URL is not found
    }
  }


  // Initializing data fetching when the widget is created
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Building the UI of the Home widget
  @override
  Widget build(BuildContext context) {
        // Extracting the selected station name from the widget
    String selectedStation = widget.selectedStation;

    // Calculating card dimensions based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardsPerRow = 3;
    final cardSpacing = 120.0;
    final cardWidth =
        (screenWidth - (cardsPerRow - 1) * cardSpacing) / cardsPerRow;
    final cardHeight = cardWidth + 30;

    // Building the scaffold with an app bar and a scrollable body
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
 // Displaying a welcome message for the selected station
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Welcome To $selectedStation Station',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
       // Displaying amenity cards in rows based on staticData and dataa
              Column(
                children: List.generate(
                  (staticData.length / cardsPerRow).ceil(),
                  (rowIndex) {
                    final int startIdx = rowIndex * cardsPerRow;
                    final int endIdx =
                        (startIdx + cardsPerRow > staticData.length)
                            ? staticData.length
                            : startIdx + cardsPerRow;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          staticData.sublist(startIdx, endIdx).map((item) {
                        // final bool isTaxi = item['value'] == 'Taxi Stand';
                        if (
                          // isTaxi ||
                            dataa.any((apiItem) =>
                                apiItem['amenity_type']
                                    .toString()
                                    .toLowerCase() ==
                                item['value'].toString().toLowerCase())) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                // if (item['value'] == 'Taxi Stand') {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => TaxiList(
                                //         stnName: selectedStation,
                                //         amenityType: item['value'],
                                //       ),
                                //     ),
                                //   );
                                // } 
                               if (item['value'] == 'Porter') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PorterWebview(
                                        url:
                                            'https://scrailway.co.in/webops/php/liscporterforapp/#/inputreq',
                                      ),
                                    ),
                                  );
                                } else if (item['value'] == 'TAD') {
                                  final tadUrl = await fetchtaddata();
                                  if (tadUrl.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TadWebview(
                                          url: tadUrl,
                                          station:
                                              selectedStation,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AmenitiesList(
                                        stnName: selectedStation,
                                        amenityType: item['value'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: cardWidth,
                                height: cardHeight,
                                child: Card(
                                  elevation: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        item['image'],
                                        fit: BoxFit.contain,
                                        height: cardWidth * 0.6,
                                        width: cardWidth * 0.6,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink(); // Hide the card
                        }
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
