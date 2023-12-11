// Import necessary packages and libraries
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities/screens/webView.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scr_amenities/screens/base_url.dart';

// Define a data class representing geographical coordinates and a platform
class GridPoint {
  final double latitude;
  final double longitude;
  final String platform;

  GridPoint(
      {required this.latitude,
      required this.longitude,
      required this.platform});

  // Factory method to create a GridPoint from JSON data
  factory GridPoint.fromJson(Map<String, dynamic> json) {
    return GridPoint(
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
      platform: json['platform'] as String,
    );
  }
}

// Define a StatefulWidget for the AmenitiesList screen
class AmenitiesList extends StatefulWidget {
  final String stnName;
  final String amenityType;

  const AmenitiesList({
    Key? key,
    required this.stnName,
    required this.amenityType,
  }) : super(key: key);

  @override
  _AmenitiesListState createState() => _AmenitiesListState();
}

// Define the state for the AmenitiesList screen
class _AmenitiesListState extends State<AmenitiesList> {
    // Declare variables to store data
  List<Map<String, dynamic>> dataa = [];
  late Future<List<Map<String, dynamic>>> amenitiesData;
  late Future<String> webviewUrl;
  bool isItemListVisible = false;
  List<Map<String, dynamic>> itemList = [];
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _accuracy = 0.0;
  late Future<List<GridPoint>> gridPoints;
  List<String> nearestLocations = [];
  String selectedPlatform = '';
  String selectedLatitude = '';
  String selectedLongitude = '';
  List<String> platforms = []; // List to store platforms
  List<DropdownMenuItem<String>> platformsDropdownItems = []; // Dropdown items

  @override
  void initState() {
    super.initState();
        // Initialize data fetching and location retrieval
    amenitiesData = fetchData();
    webviewUrl = fetchWebviewUrl();
    _getUserLocation();
    // Fetch and process additional data based on station name
    fetchLocationName().then((locationName) {
      gridPoints = fetchGridPoints(locationName);
      getCompleteData(locationName);

      // Fetch platforms based on the station name
      fetchPlatforms(widget.stnName).then((platforms) {
        // Use a Set to eliminate duplicate platform values
        final uniquePlatforms = platforms
            .map<String>(
              (platformData) => platformData['platform'] as String,
            )
            .toSet()
            .toList();

        setState(() {
          nearestLocations = platforms
              .map(
                (platformData) =>
                    "${platformData['platform']} (${platformData['latitude']}, ${platformData['longitude']})",
              )
              .toList();
          this.platforms = uniquePlatforms;

          if (uniquePlatforms.isNotEmpty) {
            selectedPlatform =
                uniquePlatforms[0]; // Set the default selected platform
          }

          // Update platformsDropdownItems
          platformsDropdownItems =
              uniquePlatforms.map<DropdownMenuItem<String>>(
            (platformValue) {
              return DropdownMenuItem<String>(
                value: platformValue,
                child: Text(platformValue),
              );
            },
          ).toList();

          // Print the platforms list
          print('$uniquePlatforms');
        });
      }).catchError((error) {
        print('Error fetching platforms: $error');
      });
    });
  }

  Future<String> fetchLocationName() async {
    final data = await amenitiesData;
    if (data.isNotEmpty) {
      return data[0]['location_name'] as String;
    } else {
      return '';
    }
  }

  Future<void> getCompleteData(String locationName) async {
    final String url = base_url + '/getstationalldetails';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'station': widget.stnName,
      }),
    );

    if (response.statusCode == 200) {
      print('API Response: ${response.body}');
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        setState(() {
          dataa = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        print('API Status: No data found.');
      }
    } else {
      print('API Error: ${response.statusCode}');
      // Handle error
    }
  }

  Future<void> _getUserLocation() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _accuracy = position.accuracy;
        });

        print('Latitude: $_latitude');
        print('Longitude: $_longitude');
        print('Accuracy: ${position.accuracy} meters');
      } catch (e) {
        print(e);
      }
    } else if (status.isDenied) {
      print('Location permission is denied.');
    } else if (status.isPermanentlyDenied) {
      print('Location permission is permanently denied.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPlatforms(String station) async {
    final apiUrl = base_url + '/getplatforms';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'station': widget.stnName,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        final platformsData = responseData.map((item) {
          final platform = item['platform'] as String;
          final latitude = double.tryParse(item['latitude'] as String) ?? 0.0;
          final longitude = double.tryParse(item['longitude'] as String) ?? 0.0;
          return {
            'platform': platform,
            'latitude': latitude,
            'longitude': longitude,
          };
        }).toList();
        return platformsData;
      } else {
        throw Exception('Invalid data format received from API');
      }
    } else {
      throw Exception(
          'Failed to fetch platforms from API: ${response.statusCode}');
    }
  }

  Future<List<GridPoint>> fetchGridPoints(String locationName) async {
    final String gridPointsUrl = base_url + '/getgridviewpoints';

    final body = {
      'station': widget.stnName,
    };

    try {
      final response = await http.post(Uri.parse(gridPointsUrl), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final gridPointList =
              jsonData.map((json) => GridPoint.fromJson(json)).toList();

          for (var gridPoint in gridPointList) {
            print(
                'Grid Point - Latitude: ${gridPoint.latitude}, Longitude: ${gridPoint.longitude}');
          }

          return gridPointList;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch grid points from API: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching grid points: $error');
      return [];
    }
  }

  Future<String> fetchWebviewUrl() async {
    final String url = base_url + '/getmapurl';
    final body = {
      'station': widget.stnName,
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          final firstMap = jsonData[0] as Map<String, dynamic>;
          final url = firstMap['url'] as String?;
          if (url != null && url.isNotEmpty) {
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

  Future<void> openGoogleChrome(String url) async {
    final chromeUrl = 'googlechrome://navigate?url=$url';
    try {
      await launch(chromeUrl);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to launch Google Chrome.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final String url = base_url + '/getstalldetails';
    final body = {
      'stnName': widget.stnName,
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);
          return data;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data from API: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return [];
    }
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Navigation'),
          content: Text(
              'You are about to navigate to a third-party application. Do you want to continue?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel navigation
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm navigation
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return result ??
        false; // Return false if the dialog is dismissed without a choice
  }

  Future<List<Map<String, dynamic>>> fetchItem() async {
    final String url = base_url + '/getItemsList';
    final body = {
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);
          return data;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data from API: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return [];
    }
  }

  Future<void> openGoogleMaps(
    double destLatitude,
    double destLongitude,
    String locationName,
  ) async {
    final gridPointList = await gridPoints;
    if (gridPointList.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No grid points available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    GridPoint nearestGridPoint = gridPointList[0];
    double minDistance = double.infinity;
    for (final gridPoint in gridPointList) {
      final distance = Geolocator.distanceBetween(
        _latitude,
        _longitude,
        gridPoint.latitude,
        gridPoint.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestGridPoint = gridPoint;
      }
    }

    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${nearestGridPoint.latitude},${nearestGridPoint.longitude}&destination=$destLatitude,$destLongitude&travelmode=walking';

    openGoogleChrome(url);
  }

  Future<void> showItemListModal(String itemId) async {
    itemList = await fetchItem();
    setState(() {
      isItemListVisible = itemList.isNotEmpty;
    });
  }

  Future<bool> checkGridPoints(Map<String, dynamic> item) async {
    final gridPointsList = await gridPoints;
    return gridPointsList != null && gridPointsList.isNotEmpty;
  }

  Future<void> _showAmenitySelector(
    String locationName,
    double destLatitude,
    double destLongitude,
  ) async {
    final List<GridPoint> gridPointList = await gridPoints;

    if (gridPointList.isEmpty) {
      // No grid points available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No grid points available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String selectedPlatform = ''; // Initialize selectedPlatform

    // Show the modal bottom sheet with the dropdown
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select the precise location ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value:
                        selectedPlatform.isNotEmpty ? selectedPlatform : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPlatform = newValue ?? '';
                      });
                    },
                    items: platformsDropdownItems,
                    hint: Text('Select a platform'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedPlatform.isEmpty) {
                        // Ensure a platform is selected
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Please select a platform.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      // Filter grid points by the selected platform
                      final List<GridPoint> filteredGridPoints =
                          gridPointList.where((gridPoint) {
                        // Assuming each GridPoint has a platform property
                        return gridPoint.platform == selectedPlatform;
                      }).toList();

                      if (filteredGridPoints.isEmpty) {
                        // No grid points available for the selected platform
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'No grid points available for the selected platform.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      // Calculate the nearest grid point from the current location
                      GridPoint nearestGridPoint = filteredGridPoints[0];
                      double minDistance = double.infinity;

                      for (final gridPoint in filteredGridPoints) {
                        final distance = Geolocator.distanceBetween(
                          _latitude,
                          _longitude,
                          gridPoint.latitude,
                          gridPoint.longitude,
                        );

                        if (distance < minDistance) {
                          minDistance = distance;
                          nearestGridPoint = gridPoint;
                        }
                      }

                      final nearestLatitude = nearestGridPoint.latitude;
                      final nearestLongitude = nearestGridPoint.longitude;

                      // Now you have the nearest grid point based on the selected platform
                      // and can use it as the origin for directions

                      final mapsUrl =
                          'https://www.google.com/maps/dir/?api=1&origin=${nearestGridPoint.latitude},${nearestGridPoint.longitude}&destination=$destLatitude,$destLongitude&travelmode=walking';

                      // Show a snackbar warning message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Container(
                            height: 60.0, // Set the desired height
                            child: Center(
                              child: Text(
                                'You are about to leave the app and use a third-party Google Maps app.',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          action: SnackBarAction(
                            label: 'Continue',
                            onPressed: () {
                              // After a short delay, open Google Maps
                              Future.delayed(Duration(seconds: 1), () async {
                                try {
                                  // Use the launch function from the url_launcher package
                                  // to open the URL in the default browser or maps app
                                  await launch(mapsUrl);
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content:
                                            Text('Failed to open Google Maps.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              });
                            },
                          ),
                          duration: Duration(
                              seconds: 30), // Set the duration to 30 seconds
                        ),
                      );

                      // Close the modal bottom sheet
                      Navigator.pop(context);
                    },
                    child: Text('Get Directions'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> fetchNearestLocations(String selectedPlatform) async {
    final String nearestLocations = base_url + '/getnearestLocations';

    final body = {
      'station': widget.stnName,
      'platform': selectedPlatform,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Map<String, dynamic>>>(
          future: amenitiesData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data;
              if (data != null && data.isNotEmpty) {
                return Text(
                  data[0]['amenity_type'] as String,
                  style: TextStyle(
                    //color: Colors.red,
                    fontSize: 18,
                  ),
                );
              }
            }
            return Text(
                "Loading..."); // You can provide a loading state for the title.
          },
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/background.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Container(
            padding: EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: amenitiesData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return Center(
                        child: Text(
                          'No Amenities Found.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              bool confirmNavigation =
                                  await showConfirmationDialog(context);

                              if (confirmNavigation) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Webview(
                                      stnName: widget.stnName,
                                      amenityType: widget.amenityType,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('View On Map'),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];

                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Card(
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              item['location_name']
                                                      as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Text(
                                              item['location_details']
                                                      as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              item['station_name'] as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 30),
                                            Text(
                                              'Service: ${item['service_type'] as String? ?? ''}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: FutureBuilder<bool>(
                                          future: checkGridPoints(item),
                                          builder: (context, snapshot) {
                                            final showNearestLocationButton =
                                                snapshot.data == true;

                                            return Visibility(
                                              visible:
                                                  showNearestLocationButton,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(right: 8.0),
                                                child: ElevatedButton(
                                                  onPressed:
                                                      showNearestLocationButton
                                                          ? () {
                                                              final latitude = item[
                                                                          'latitude'] !=
                                                                      null
                                                                  ? double.parse(
                                                                      item['latitude']
                                                                          as String)
                                                                  : 0.0;
                                                              final longitude = item[
                                                                          'longitude'] !=
                                                                      null
                                                                  ? double.parse(
                                                                      item['longitude']
                                                                          as String)
                                                                  : 0.0;
                                                              final accuracy = item[
                                                                          'accuracy'] !=
                                                                      null
                                                                  ? double.parse(
                                                                      item['accuracy']
                                                                          as String)
                                                                  : 0.0;

                                                              // Set the selectedPlatform to the first platform if available
                                                              selectedPlatform = platforms
                                                                      .isNotEmpty
                                                                  ? platforms[0]
                                                                  : ''; // You can set a default value if platforms is empty

                                                              _showAmenitySelector(
                                                                item['location_name']
                                                                    as String,
                                                                latitude,
                                                                longitude,
                                                              );
                                                            }
                                                          : null,
                                                  child:
                                                      Text('Nearest Location'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.blue),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.black),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 2,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching data: ${snapshot.error}');
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
