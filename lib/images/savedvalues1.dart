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

class AreaList1 extends StatefulWidget {
  @override
  _AreaList1State createState() => _AreaList1State();
}

class _AreaList1State extends State<AreaList1> {
  final dbRef = FirebaseDatabase.instance.reference();
  final searchController = StreamController<String>();
  bool hasData = true; // Declare the variable here

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
                              'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation')
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
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    // Data is available
                    hasData = true; // Set the flag to true
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
                                    builder: (context) => PlotList(areaId: key.toString()),
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
                                        Color.fromARGB(255, 255, 255, 255), // Add a white stop here
                                        Color.fromARGB(255, 250, 250, 250), // Add another white stop here
                                      ],
                                      stops: [0.0, 0.8, 0.8, 1.0], // Adjust the stops accordingly
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: -7,  // Adjust the top position to -7 for offset
                                        right: -7, // Adjust the left position to -7 for offset
                                        child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteArea(key); // Call the delete function with the areaId
                                          },
                                          color: Colors.white,
                                        ),
                                      ),
                                      Center( // Center-align the text
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                nameAbove.isNotEmpty ? nameAbove : nameBelow, // Use nameBelow if nameAbove is empty
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                            ),
                                            if (nameAbove.isNotEmpty) // Show nameBelow only if nameAbove is not empty
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
                // If loading, or no data, show a message
                return Center(
                  child: hasData
                      ? CircularProgressIndicator()
                      : Text("There is no data available at the moment"),
                );
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
            Icon(Icons.home,
                color: Colors.white), // Icon before the title
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
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/$areaId')
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
  Map<int, bool> showRecommendationMap = {};
  bool showRecommendation = false;

  List<TextEditingController> nitrogenControllers = [];
  List<TextEditingController> phosphorusControllers = [];
  List<TextEditingController> potassiumControllers = [];

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

  double parseDoubleFromValueString(String valueString) {
    int spaceIndex = valueString.indexOf(' ');
    String numericPart = valueString.substring(0, spaceIndex);
    return double.tryParse(numericPart) ?? 0.0;
  }

  void _navigateToDatasetSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DatasetSelectionScreen()),
    );
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
          IconButton(
            onPressed: _navigateToDatasetSelection,
            icon: Icon(Icons.layers),
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
      child: StreamBuilder(
        stream: dbRef
            .child('saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}')
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic>? values = snapshot.data?.snapshot.value as Map?;
            if (values != null && values.isNotEmpty) {
              return ListView.builder(
                itemCount: values.length,
                itemBuilder: (context, index) {
                  showRecommendationMap.putIfAbsent(index, () => false);
                  nitrogenControllers.add(TextEditingController());
                  phosphorusControllers.add(TextEditingController());
                  potassiumControllers.add(TextEditingController());

                  var entry = values.entries.elementAt(index);
                  Map<String, dynamic> dataObject = (entry.value['data'] as Map).cast<String, dynamic>();
                  String timestamp = entry.value['timestamp'];

                  MapEntry<String, dynamic>? recommendationEntry;
                  List<MapEntry<String, dynamic>> otherEntries = [];
                  double nitrogenValue = 0;
                  double phosphorusValue = 0;
                  double potassiumValue = 0;
                  String recommendationValue = '';

                  for (var entry in dataObject.entries) {
                    if (entry.key.toLowerCase() == 'recommendation') {
                      recommendationEntry = entry;
                      recommendationValue = entry.value.toString();
                    } else if (entry.key.toLowerCase() == 'nitrogen') {
                      nitrogenValue = parseDoubleFromValueString(entry.value);
                    } else if (entry.key.toLowerCase() == 'phosphorus') {
                      phosphorusValue = parseDoubleFromValueString(entry.value);
                    } else if (entry.key.toLowerCase() == 'potassium') {
                      potassiumValue = parseDoubleFromValueString(entry.value);
                    } else {
                      otherEntries.add(entry);
                    }
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
                          ...[  
  MapEntry('Nitrogen', '$nitrogenValue mg/kg'),
  MapEntry('Phosphorus', '$phosphorusValue mg/kg'),
  MapEntry('Potassium', '$potassiumValue mg/kg'),
  ...otherEntries,
].map((entry) {
  final parameter = entry.key;
  final value = entry.value;
  final parameterColor = parameter.toLowerCase() == 'recommendation'
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          parameter.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: parameterColor,
            fontSize: 16,
          ),
        ),
        if (parameter.toLowerCase() == 'recommendation')
          showRecommendationMap[index] == true
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14.5),
                  decoration: BoxDecoration(
                    color: parameterColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
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
                      showRecommendationMap[index] = true;
                    });
                  },
                  child: Text('Show Recommendation'),
                  style: ElevatedButton.styleFrom(
                    primary: parameterColor,
                  ),
                )
        else
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: parameterColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
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

                          

                          SizedBox(height: 16),

                          // Recommendation button
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showRecommendation = !showRecommendation;
                              });
                            },
                            child: Text(
                              showRecommendation ? 'Hide Recommendation' : 'Show Recommendation',
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orange,
                            ),
                          ),
                          if (showRecommendation) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 14.5),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                recommendationValue,
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 25),

                          // Enter recommended dose of fertilizers label
                          Text(
                            'FERTILIZER SUGGESTION',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 85, 183, 58),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),




                          // Text fields for Nitrogen, Phosphorus, and Potassium
                          // Inside the TextField for Nitrogen
                         Container(
  margin: EdgeInsets.only(bottom: 16),
  child: Row(
    children: [
      Container(
        width: 100, // Adjust the width as needed
        child: Text(
          'NITROGEN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple, // Change the text color
          ),
        ),
      ),
      SizedBox(width: 84), // Add spacing between label and value
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[200], // Background color for the value
        ),
        child: Text(
          'Placeholder Value', // You can replace this with the actual value later
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple, // Change the text color
          ),
        ),
      ),
    ],
  ),
),

Container(
  margin: EdgeInsets.only(bottom: 16),
  child: Row(
    children: [
      Container(
        width: 106,
        child: Text(
          'PHOSPHORUS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      SizedBox(width: 78),
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[200],
        ),
        child: Text(
          'Placeholder Value',
          style: TextStyle(
            
            fontSize: 16,
            color: const Color.fromARGB(255, 244, 243, 247),
          ),
        ),
      ),
    ],
  ),
),

Container(
  margin: EdgeInsets.only(bottom: 16),
  child: Row(
    children: [
      Container(
        width: 100,
        child: Text(
          'POTASSIUM',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      SizedBox(width: 84),
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[200],
        ),
        child: Text(
          'Placeholder Value',
          style: TextStyle(
            fontSize: 16,
            color: Colors.deepPurple,
          ),
        ),
      ),
    ],
  ),
),
ElevatedButton(
                              onPressed: () {
                                captureAndShare(); // Capture and share the screenshot
                              },
                              child: Text('Share Data'),
                            ),
                      
                      
                  
                      



                          SizedBox(height: 0),

                          // Update button for entering fertilizer values
                         
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

class DatasetSelectionScreen extends StatefulWidget {
  @override
  _DatasetSelectionScreenState createState() => _DatasetSelectionScreenState();
}

class _DatasetSelectionScreenState extends State<DatasetSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dataset'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildDatasetTile(
            title: 'Soil Types',
            gradientColors: [
              Colors.blue,
              Color.fromARGB(255, 7, 4, 18),
               
            ],
            items: {
              'Loamy': 2,
              'Clayey': 1,
              'Sandy': 4,
              'Black': 0,
              'Red': 3,
            },
          ),
          _buildDatasetTile(
            title: 'Crop Types',
            gradientColors: [
              Colors.blue,
              Color.fromARGB(255, 4, 2, 1),
            ],
            items: {
              'Wheat': 10,
              'Maize': 3,
              'Cotton': 1,
              'Tobacco': 9,
              'Paddy': 6,
              'Barley': 0,
              'Sugarcane': 8,
              'Millets': 4,
              'Oil seeds': 5,
              'Ground Nuts': 2,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetTile({
    required String title,
    required List<Color> gradientColors,
    required Map<String, int> items,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 14, horizontal: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ExpansionTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            children: items.entries.map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}