import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img; // Rename the imported Image class
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AreaList extends StatefulWidget {
  @override
  _AreaListState createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  final dbRef = FirebaseDatabase.instance.reference();
  final searchController = StreamController<String>();

  @override
  void dispose() {
    searchController.close();
    super.dispose();
  }

  void _deleteArea(String areaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 48,
              ),
              SizedBox(height: 20),
              Text(
                "Confirm Delete",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to delete this area?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      dbRef
                          .child(
                              'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recomendations')
                          .child(areaId)
                          .remove()
                          .then((_) {
                        print("Delete successful");
                        Navigator.of(context).pop(); // Close the dialog
                      }).catchError((error) {
                        print("Delete failed: $error");
                        Navigator.of(context).pop(); // Close the dialog
                      });
                    },
                    child: Text("Delete"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueGrey[200], // Change the color here
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromARGB(255, 4, 2, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Field',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  onChanged: (query) => searchController.add(query),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: dbRef
                  .child(
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recomendations')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    List<String> keys = values.keys.cast<String>().toList();
                    keys.sort();

                    return StreamBuilder<String>(
                      stream: searchController.stream,
                      builder: (context, searchSnapshot) {
                        final searchQuery =
                            searchSnapshot.data?.toLowerCase() ?? '';

                        final filteredKeys = keys
                            .where((key) =>
                                key.toLowerCase().contains(searchQuery))
                            .toList();

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredKeys.length,
                          itemBuilder: (context, index) {
                            String key = filteredKeys[index];
                            final parts = key.split(':'); // Split by ":"
                            final nameAbove = parts[0];
                            final nameBelow = parts.length > 1 ? parts[1] : '';

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlotList(areaId: key.toString()),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Color.fromARGB(255, 4, 2, 1),
                                        Colors.white, // Add a white stop here
                                        Colors
                                            .white, // Add another white stop here
                                      ],
                                      stops: [
                                        0.0,
                                        0.8,
                                        0.8,
                                        1.0
                                      ], // Adjust the stops accordingly
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top:
                                            -7, // Adjust the top position to -7 for offset
                                        right:
                                            -7, // Adjust the left position to -7 for offset
                                        child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteArea(
                                                key); // Call the delete function with the areaId
                                          },
                                          color: Colors.white,
                                        ),
                                      ),
                                      Center(
                                        // Center-align the text
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                nameAbove.isNotEmpty
                                                    ? nameAbove
                                                    : nameBelow, // Use nameBelow if nameAbove is empty
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                            ),
                                            if (nameAbove
                                                .isNotEmpty) // Show nameBelow only if nameAbove is not empty
                                              Text(
                                                nameBelow,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
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

class PlotList extends StatelessWidget {
  final dbRef = FirebaseDatabase.instance.reference();
  final String areaId;

  PlotList({required this.areaId});

  final searchController = StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 33, 150, 243), // Blue Gradient Start Color
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromARGB(255, 4, 2, 1),
              ], // Blue and Dark Blue Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.white), // Icon before the title
            SizedBox(width: 8),
            Text(
              'Plots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  onChanged: (query) => searchController.add(query),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: dbRef
                  .child(
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recomendations/$areaId')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    List<String> keys = values.keys.cast<String>().toList();
                    keys.sort();

                    return StreamBuilder<String>(
                      stream: searchController.stream,
                      builder: (context, searchSnapshot) {
                        final searchQuery =
                            searchSnapshot.data?.toLowerCase() ?? '';

                        final filteredKeys = keys
                            .where((key) =>
                                key.toLowerCase().contains(searchQuery))
                            .toList();

                        return ListView.builder(
                          itemCount: filteredKeys.length,
                          itemBuilder: (context, index) {
                            String key = filteredKeys[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DataList(
                                        areaId: areaId, plotId: key.toString()),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Color.fromARGB(255, 4, 2, 1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        key.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
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

void main() {
  runApp(MaterialApp(
    home: DataList(areaId: 'yourAreaId', plotId: 'yourPlotId'),
  ));
}

class DataList extends StatefulWidget {
  final String areaId;
  final String plotId;

  

  DataList({required this.areaId, required this.plotId});

  @override
  _DataListState createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  final dbRef = FirebaseDatabase.instance.reference();
  Map<String, bool> predictionVisibilityMap =
      {}; // Map to store prediction visibility state
  TextEditingController averageController = TextEditingController();

  String timeToDate(String timestampString) {
    var timestamp = int.parse(timestampString);
    var isMilliseconds = timestampString.length == 13;
    if (isMilliseconds) {
      timestamp = timestamp ~/ 1000;
    }

    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var formattedTime = DateFormat('kk:mm').format(date);
    var formattedDate = DateFormat('dd/MM/yy').format(date);
    return '$formattedTime - $formattedDate';
  }

  String plotId = ''; // Replace with the appropriate types and initial values
  String areaId = '';
  String userName = '';
  String timestamp = '';

  Future<void> callServerFunction(String plotId, String areaId, String userName,
      String timestamp, String N, String P, String K) async {
    final url =
        'https://mlbackend--croprecommendat.repl.co/fertilizer_function';

    final headers = {'Content-Type': 'application/json'};
    final plot = plotId;
    final area = areaId;
    final user = userName;
    final userN = N;
    final userP = P;
    final userK = K;
    final requestdata = {
      'user': user,
      'area': area,
      'plot': plot,
      'timestamp': timestamp,
      'userN': userN,
      'userP': userP,
      'userK': userK
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(requestdata));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['result'];
      print('Result from server: $result');
    } else {
      print('Failed to call server function');
    }
  }

  Future<void> callServerFunctioncrop(
      String plotId, String areaId, String userName, String timestamp) async {
    final url = 'https://mlbackend--croprecommendat.repl.co/crop_function';

    final headers = {'Content-Type': 'application/json'};
    final plot = plotId;
    final area = areaId;
    final user = userName;
    final requestdata = {
      'user': user,
      'area': area,
      'plot': plot,
      'timestamp': timestamp
    };


    try {
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(requestdata),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body)['result'];
    print('Result from server: $result');
  } else {
    print('Failed to call server function. Status code: ${response.statusCode}');
  }
} catch (e) {
  print('An error occurred while calling the server function: $e');
}

  }

  @override
   void initState(){
    super.initState();
    areaId = widget.areaId;
    plotId = widget.plotId;
   }

  /////////////////////////code///////////
  ///
  ///
  ////////////////////
  ///
  ///////
  ////
  ////
  ////
  ///////////////////////
  ///

  

  final ScreenshotController _screenshotController = ScreenshotController();

  // Function to capture and share the screenshot
  void captureAndShare() async {
    Uint8List? bytes = await _screenshotController.capture();

    if (bytes != null) {
      img.Image image = img.decodeImage(bytes)!;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/screenshot.png');
      await file.writeAsBytes(img.encodePng(image));

      await Share.shareFiles([file.path], text: 'Shared Data Screenshot');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromARGB(255, 4, 2, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.data_usage, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Saved Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
       actions: [
  TextButton(
    onPressed: () {
      // callServerFunctioncrop(plotId, areaId, userName, timestamp);
      // Switch to the averaged data tab or screen.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AveragedDataScreen(
            areaId: widget.areaId,
            plotId: widget.plotId,
          ),
        ),
      );
    },
    child: Text('Crop Prediction'),
  ),
],

      ),
      body: Screenshot(
        controller: _screenshotController,
        child: StreamBuilder(
          stream: dbRef
              .child(
                  'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recomendations/${widget.areaId}/${widget.plotId}')
              .onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasData) {
              Map<dynamic, dynamic>? values =
                  snapshot.data?.snapshot.value as Map?;
              if (values != null && values.isNotEmpty) {
                return ListView.builder(
                  itemCount: values.length,
                  itemBuilder: (context, index) {
                    var entry = values.entries.elementAt(index);
                    Map<String, dynamic> dataObject =
                        (entry.value['data'] as Map).cast<String, dynamic>();
                    String timestamp = entry.value['timestamp'];

                    MapEntry<String, dynamic>? predictionEntry;
                    List<MapEntry<String, dynamic>> otherEntries = [];
                    for (var entry in dataObject.entries) {
                      if (entry.key.toLowerCase() == 'prediction') {
                        predictionEntry = entry;
                      } else {
                        otherEntries.add(entry);
                      }
                    }

                    if (predictionEntry != null) {
                      otherEntries.add(predictionEntry);
                    }

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Timestamp:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  timeToDate(timestamp),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ...otherEntries.map((entry) {
                              final parameter = entry.key;
                              final value = entry.value;
                              final parameterColor =
                                  parameter.toLowerCase() == 'prediction'
                                      ? Colors.orange
                                      : Colors.deepPurple;

                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      parameter.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: parameterColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (parameter.toLowerCase() == 'prediction')
                                      predictionVisibilityMap[timestamp] == true
                                          ? Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25,
                                                  vertical: 14.5),
                                              decoration: BoxDecoration(
                                                color: parameterColor
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                value.toString(),
                                                style: TextStyle(
                                                  color: parameterColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  predictionVisibilityMap[
                                                      timestamp] = true;
                                                });
                                              },
                                              child: Text('Show Prediction'),
                                              style: ElevatedButton.styleFrom(
                                                primary: parameterColor,
                                              ),
                                            )
                                    else
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              parameterColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          value.toString(),
                                          style: TextStyle(
                                            color: parameterColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            // ElevatedButton(
                            //   onPressed: () {
                            //    // Calculate and save averages
                            //   calculateAndSaveAverages(dataObject);
                            //  },
                            // child: Text('Calculate Average'),
                            // ),
                            // TextField(
                            //   controller: averageController,
                            //   decoration: InputDecoration(
                            //     labelText: 'Average Value',
                            //   ),
                            //  ),
                            ElevatedButton(
                              onPressed: () {
                                captureAndShare(); // Capture and share the screenshot
                              },
                              child: Text('Share Data'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class AveragedDataScreen extends StatefulWidget {
  final String areaId;
  final String plotId;

  AveragedDataScreen({required this.areaId, required this.plotId});

  @override
  _AveragedDataScreenState createState() => _AveragedDataScreenState();
}

class _AveragedDataScreenState extends State<AveragedDataScreen> {
  final dbRef = FirebaseDatabase.instance.reference();
  DateTime selectedDate = DateTime.now();
  Map<String, Map<String, dynamic>> parameterAverages = {};

  String formatDecimal(double value) {
    return value.toStringAsFixed(2);
  }

  // Function to call the server function for crop prediction
  Future<void> callServerFunctioncrop(
      String plotId, String areaId, String userName, String timestamp) async {
    final url = 'https://mlbackend--croprecommendat.repl.co/crop_function';

    final headers = {'Content-Type': 'application/json'};
    final plot = plotId;
    final area = areaId;
    final user = userName;
    final requestdata = {
      'user': user,
      'area': area,
      'plot': plot,
      'timestamp': timestamp
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestdata),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['result'];
        print('Result from server: $result');
        // You can handle the result here, such as updating UI.
      } else {
        print('Failed to call server function. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred while calling the server function: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crop Prediction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Colors.blue, Colors.black],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text('Select Date'),
                ),
              ],
            ),
          ),

          
          // Predict button to call the server function
         // Predict button to call the server function








          Expanded(
            child: StreamBuilder(
              stream: dbRef
                  .child(
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recomendations/${widget.areaId}/${widget.plotId}')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    parameterAverages.clear(); // Clear the previous data

                    // Filter data based on selected date
                    values.forEach((timestamp, dataObject) {
                      if (timestamp is String) {
                        int timestampInt = int.tryParse(timestamp) ?? 0;
                        DateTime dataDate =
                            DateTime.fromMillisecondsSinceEpoch(timestampInt);

                        if (dataDate.day == selectedDate.day &&
                            dataDate.month == selectedDate.month &&
                            dataDate.year == selectedDate.year) {
                          Map<String, dynamic> data =
                              (dataObject['data'] as Map)
                                  .cast<String, dynamic>();

                          data.forEach((parameter, value) {
                            if (value is String) {
                              var cleanedValue = double.tryParse(
                                  value.replaceAll(RegExp(r'[^\d.]'), ''));
                              if (cleanedValue != null) {
                                if (parameterAverages.containsKey(parameter)) {
                                  parameterAverages[parameter]!['sum'] +=
                                      cleanedValue;
                                  parameterAverages[parameter]!['count']++;
                                } else {
                                  parameterAverages[parameter] = {
                                    'sum': cleanedValue,
                                    'count': 1,
                                  };
                                }
                              }
                            }
                          });
                        }
                      }
                    });

                    if (parameterAverages.isEmpty) {
                      // Display the "No data" image if parameterAverages is empty
                      return Center(
                        child: Image.asset(
                          'lib/images/2000.jpg',
                          width: 350, // Adjust the width as needed
                          height: 350, // Adjust the height as needed
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: parameterAverages.length,
                        itemBuilder: (context, index) {
                          // Your existing code for displaying data
                          var parameter =
                              parameterAverages.keys.elementAt(index);
                          var sum = parameterAverages[parameter]!['sum'];
                          var count = parameterAverages[parameter]!['count'];
                          var average = count > 0 ? sum / count : 0.0;
                          var unit = '';

                          switch (parameter) {
                            case 'moisture':
                              unit = '%';
                              break;
                            case 'humidity':
                              unit = '%';
                              break;
                            case 'ec':
                              unit = 'uS/cm';
                              break;
                            case 'temperature':
                              unit = '°C';
                              break;
                          }

                          dbRef
                              .child(
                                  'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recommendations/${widget.areaId}/${widget.plotId}/$parameter')
                              .set({
                            'average': average,
                            'unit': unit,
                          });

                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Averaged $parameter Data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          parameter.toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${formatDecimal(average)} $unit',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          ElevatedButton(
  onPressed: () {
    // Call the server function when the Predict button is pressed
    callServerFunctioncrop(
      widget.plotId,
      widget.areaId,
      FirebaseAuth.instance.currentUser?.displayName ?? "",
      selectedDate.toUtc().millisecondsSinceEpoch.toString(),
    );
  },
  child: Text('Predict'),
),
Text(
  '',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.black,
  ),
),
StreamBuilder(
  stream: dbRef
    .child(
      'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Crop Recommendations/${widget.areaId}/${widget.plotId}/u_prediction',
    )
    .onValue,
  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.hasData) {
      // Check if the value is available
      if (snapshot.data?.snapshot.value != null) {
        var uPredictionValue = snapshot.data?.snapshot.value.toString();
        return Container(
  decoration: BoxDecoration(
    color: Colors.blue, // You can choose any background color you like
    borderRadius: BorderRadius.circular(10), // Add rounded corners if desired
  ),
  padding: EdgeInsets.all(8), // Adjust padding as needed
  child: Text(
    '$uPredictionValue',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white, // Text color
    ),
  ),
);

      } else {
        return Text(
          '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        );
      }
    }
    return Center(child: CircularProgressIndicator());
  },
),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
