import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:scr_amenities/screens/base_url.dart';

class TaxiList extends StatefulWidget {
  final String stnName;
  final String amenityType;

  const TaxiList({
    Key? key,
    required this.stnName,
    required this.amenityType,
  }) : super(key: key);

  @override
  _TaxiListState createState() => _TaxiListState();
}

class _TaxiListState extends State<TaxiList> {
  late Future<List<Map<String, dynamic>>> taxiData;
  List<Map<String, dynamic>> itemList = [];

  @override
  void initState() {
    super.initState();
    taxiData = fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final String url = base_url + '/gettaxidetails';
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

  void _launchPhoneCall(String? phoneNumber) async {
    if (phoneNumber != null) {
      try {
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to make a phone call.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Invalid phone number.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Taxi List'),
    ),
    body: Container(
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: taxiData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'No Taxi Found.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            itemList = data; // Update the itemList

            return SingleChildScrollView(
              child: Column(
                children: [
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
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  item['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  item['mobile_no'] as String? ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.call),
                              onPressed: () {
                                _launchPhoneCall(item['mobile_no'] as String?);
                              },
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error fetching data: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    ),
  );
}
}