import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
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
  bool showFertilizerSuggestion = false; // Add this variable
  bool showSuggestedFertilizer = false;

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

   String areaId = ''; // Initialize with empty strings
  String plotId = '';
  String userName = '';
  String timestamp = '';
  String N = '';
  String P = '';
  String K = '';

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

 @override
  void initState() {
    super.initState();
    // Initialize the variables using the widget's values
    areaId = widget.areaId;
    plotId = widget.plotId;
    // You should initialize other variables here as well if needed.
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

   // Function to parse the numeric values from the value string
  double parseDoubleFromValueString(String valueString) {
    // Remove any non-numeric characters and parse the double
    String numericPart = valueString.replaceAll(RegExp(r'[^0-9.]'), '');
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
           
          TextButton(
  onPressed: () {
    // callServerFunction(plotId, areaId, userName, timestamp, N, P, K);
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
  child: Text('Fertilizer Prediction'),
),


        
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

                  var entry = values.entries.elementAt(index);
                  Map<String, dynamic> dataObject = (entry.value['data'] as Map).cast<String, dynamic>();
                  String timestamp = entry.value['timestamp'];

                  MapEntry<String, dynamic>? recommendationEntry;
                  List<MapEntry<String, dynamic>> otherEntries = [];
                  double nitrogenValue = 0;
                  double phosphorusValue = 0;
                  double potassiumValue = 0;
                  double rn = 0;
                  double rp = 0;
                  double rpm = 0;
                  double fq = 0;
                  String recommendationValue = '';

                  for (var entry in dataObject.entries) {
                    if (entry.key.toLowerCase() == 'recommendation') {
                      recommendationEntry = entry;
                      recommendationValue = entry.value.toString();
                    } else if (entry.key.toLowerCase() == 'nitrogen') {
                      nitrogenValue = parseDoubleFromValueString(entry.value);
                    } else if (entry.key.toLowerCase() == 'phosphorus') {
                      phosphorusValue = parseDoubleFromValueString(entry.value);
                    } else if (entry.key.toLowerCase() == 'recommended_nitrogen') {
                      rn = parseDoubleFromValueString(entry.value);


                       } else if (entry.key.toLowerCase() == 'recommended_phosphorous') {
                      rp = parseDoubleFromValueString(entry.value);
                      } else if (entry.key.toLowerCase() == 'fertilizer_quantity') {
                      fq = parseDoubleFromValueString(entry.value);
                       } else if (entry.key.toLowerCase() == 'recommended_pottasium') {
                      rpm = parseDoubleFromValueString(entry.value);

                       } else if (entry.key.toLowerCase() == 'potassium') {
                      potassiumValue = parseDoubleFromValueString(entry.value);
                    } else {

                      otherEntries.add(entry);
                    }
                  }

                 // Inside the itemBuilder of the ListView.builder
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
  if (nitrogenValue != 0)
    MapEntry('Nitrogen', '$nitrogenValue mg/kg'),
  if (phosphorusValue != 0)
    MapEntry('Phosphorus', '$phosphorusValue mg/kg'),
  if (potassiumValue != 0)
    MapEntry('Potassium', '$potassiumValue mg/kg'),
  ...otherEntries.where((entry) =>
      entry.key.toLowerCase() != 'recommended_nitrogen' &&
      entry.key.toLowerCase() != 'recommended_phosphorous' &&
      entry.key.toLowerCase() != 'fertilizer_quantity' &&
      entry.key.toLowerCase() != 'recommended_pottasium'), // Exclude the unwanted entries
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
                          // Recommendation button with adjustable width
                //  Container(
               //     width: 400, // Adjust the width as needed
               //     child: ElevatedButton(
              ///        onPressed: () {
              //          setState(() {
              ////            showRecommendation = !showRecommendation;
                 //       });
                //      },
                //      child: Text(
                //        showRecommendation ? 'Hide Recommended Fertilier' : 'Show Recommendation Fertilizer',
                //      ),
                ///      style: ElevatedButton.styleFrom(
                //        primary: Colors.orange,
                //      ),
                //    ),
                //  ),
               //   if (showRecommendation) ...[
               //             Container(
                              
                                
                   //           padding: EdgeInsets.symmetric(horizontal: 142, vertical: 10),
                    //          decoration: BoxDecoration(
                    //            color: Colors.orange.withOpacity(0.2),
                     //           borderRadius: BorderRadius.circular(4),
                     //         ),
                     //         child: Text(
                     //           recommendationValue,
                     //           style: TextStyle(
                     //             color: Colors.orange,
                      //            fontSize: 16,
                      //          ),
                      //        ),
                      //      ),
                     //     ],

                     //     SizedBox(height: 2),

                          
                         // Define a boolean variable to control the visibility of the text label


// Add an additional button and text label
//Container(
 // width: 400, // Adjust the width as needed
  //child: ElevatedButton(
  //  onPressed: () {
  //    setState(() {
  //      showSuggestedFertilizer = !showSuggestedFertilizer;
   //   });
   // },
   // child: Text(
   //   showSuggestedFertilizer ? 'Hide Suggestion for Recomended Fertilizer ' : "Show Suggestion for Recomended Fertilizer",
    ///),
    //style: ElevatedButton.styleFrom(
    //  primary: Colors.blue, // Set the button color as you like
   // ),
  //),
//),
//if (showSuggestedFertilizer) ...[
  //Container(
   // padding: EdgeInsets.symmetric(horizontal: 122, vertical: 10),
   // decoration: BoxDecoration(
      //olor: Colors.blue.withOpacity(0.2),
     // borderRadius: BorderRadius.circular(4),
   // ),//
    //child: Text(
     // '${fq.toStringAsFixed(2)} Kg/Acre',
      //style: TextStyle(
      //  color: Colors.blue,
      //  fontSize: 16,
     // ),
 //   //),
 // ),
//],




                          // Enter recommended dose of fertilizers label
                          // Fertilizer Suggestion button with adjustable width
               //   Container(
               //     width: 400, // Set the width as needed
               //     child: ElevatedButton(
                //      onPressed: () {
                //        setState(() {
                //          showFertilizerSuggestion = !showFertilizerSuggestion;
                //        });
                //      },
                //      child: Text(
                //        showFertilizerSuggestion ? 'Hide Stright Firtilizer Quantity' : 'Show Stright Fertilizer Quantity',
                 //     ),
                //      style: ElevatedButton.styleFrom(
               //         primary: Colors.green, // Set the button color to green
              //        ),
              //      ),
              //    ),
              //    if (showFertilizerSuggestion) ...[
                //          SizedBox(height: 15),
//



                          // Text fields for Nitrogen, Phosphorus, and Potassium
                          // Inside the TextField for Nitrogen




                        // Container(
  //margin: EdgeInsets.only(bottom: 16),
  //child: Row(
   // children: [
    // Container(
       // width: 100, // Adjust the width as needed
     //   child: Text(
      //    'NITROGEN',
       //   style: TextStyle(
       //     fontSize: 16,
       //     fontWeight: FontWeight.bold,
       //     color: Colors.deepPurple, // Change the text color
      //    ),
    //    ),
    ///  ),
     // SizedBox(width: 84), // Add spacing between label and value
     // Container(
      //  padding: EdgeInsets.all(8),
     //  decoration: BoxDecoration(
      //    borderRadius: BorderRadius.circular(5),
      //    color: Colors.grey[200], // Background color for the value
      //  ),
     //   child: Text(
       //   '${rn.toStringAsFixed(2)} Kg/Acre', // You can replace this with the actual value later
         // style: TextStyle(
         //   fontSize: 16,
      //      color: Colors.deepPurple, // Change the text color
     //     ),
    //    ),
   //   ),
 //   ],
  //),
//),


//Container(
  //margin: EdgeInsets.only(bottom: 16),
  //child: Row(
  //  children: [
   //   Container(
   //     width: 106,
   //     child: Text(
       //   'PHOSPHORUS',
     //     style: TextStyle(
    //        fontSize: 16,
     //       fontWeight: FontWeight.bold,
     //       color: Colors.deepPurple,
      //    ),
     //   ),
     // ),
    //  SizedBox(width: 78),
     // Container(
     //   padding: EdgeInsets.all(8),
     ///   decoration: BoxDecoration(
     //     borderRadius: BorderRadius.circular(5),
        //  color: Colors.grey[200],
       // ),
      //  child: Text(
      //   '${rp.toStringAsFixed(2)} Kg/Acre',
      //    style: TextStyle(
      //      
       ////     fontSize: 16,
       //     color:Colors.deepPurple,
       //   ),
      //  ),
     // ),
   // ],
 // ),
//),

//Container(/
  //margin: EdgeInsets.only(bottom: 16),
  ///child: Row(
   // children: [
    //  Container(
      //  width: 100,
      //  child: Text(
       //   'POTASSIUM',
         // style: TextStyle(
         //   fontSize: 16,
         //   fontWeight: FontWeight.bold,
        //    color: Colors.deepPurple,
      //    ),
       // ),
     // ),
      //SizedBox(width: 84),
      //Container(
     //   padding: EdgeInsets.all(8),
      ////  decoration: BoxDecoration(
    //      borderRadius: BorderRadius.circular(5),
    //      color: Colors.grey[200],
     //   ),
     //   child: Text(
     //     '${rpm.toStringAsFixed(2)} Kg/Acre',
      //    style: TextStyle(
    //        fontSize: 16,
     //       color: Colors.deepPurple,
    ////      ),
     //   ),
   //   ),
  //  ],
 // ),
//),







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
  Map<String, Map<String, dynamic>> majorityValues = {};
  bool isButtonPressed = false;
  bool isButtonPressed1 = false;

  String formatDecimal(double value) {
    return value.toStringAsFixed(2);
  }
  


    // Function to call the server function for crop prediction
  Future<void> callServerFunctionFerti(
      String plotId, String areaId, String userName, String timestamp) async {
    final url = 'https://mlbackend--croprecommendat.repl.co/fertilizer_function';

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

  String getSoilType(int soilTypeValue) {
  switch (soilTypeValue) {
    case 0:
      return 'Black';
    case 1:
      return 'Clayey';
    case 2:
      return 'Loamy';
    case 3:
      return 'Red';
    case 4:
      return 'Sandy';
    default:
      return 'Unknown';
  }
}

String getCropType(int cropTypeValue) {
  switch (cropTypeValue) {
    case 0:
      return 'Barley';
    case 1:
      return 'Cotton';
    case 2:
      return 'Ground Nuts';
    case 3:
      return 'Maize';
    case 4:
      return 'Millets';
    case 5:
      return 'Oil seeds';
    case 6:
      return 'Paddy';
    case 8:
      return 'Sugarcane';
    case 9:
      return 'Tobacco';
    case 10:
      return 'Wheat';
    default:
      return 'Unknown';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fertilizer Recommendation',
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

          






//working ///////
/////
//////////
////////
////////
////////
////////
//////
////
////

// 
// 
// 


 





          Expanded(
            child: StreamBuilder(
              stream: dbRef
                  .child(
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic>? values =
                      snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    parameterAverages.clear();
                    majorityValues.clear();

                    values.forEach((timestamp, dataObject) {
                      if (timestamp is String) {
                        int timestampInt =
                            int.tryParse(timestamp) ?? 0;
                        DateTime dataDate =
                            DateTime.fromMillisecondsSinceEpoch(timestampInt);

                        if (dataDate.day == selectedDate.day &&
                            dataDate.month == selectedDate.month &&
                            dataDate.year == selectedDate.year) {
                          Map<String, dynamic> data =
                              (dataObject['data'] as Map).cast<String, dynamic>();

                          data.forEach((parameter, value) {
                            if (value is String) {
                              var cleanedValue =
                                  double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
                              if (cleanedValue != null) {
                                if (parameterAverages.containsKey(parameter)) {
                                  parameterAverages[parameter]!['sum'] += cleanedValue;
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

                          if (data.containsKey('soil_type')) {
                            var soilTypeValue = data['soil_type'] as int;
                            if (parameterAverages.containsKey('soil_type')) {
                              parameterAverages['soil_type']!['sum'] += soilTypeValue.toDouble();
                              parameterAverages['soil_type']!['count']++;
                            } else {
                              parameterAverages['soil_type'] = {
                                'sum': soilTypeValue.toDouble(),
                                'count': 1,
                              };
                            }

                            if (majorityValues.containsKey('soil_type')) {
                              majorityValues['soil_type']![soilTypeValue.toString()] =
                                  (majorityValues['soil_type']![soilTypeValue.toString()] ?? 0) + 1;
                            } else {
                              majorityValues['soil_type'] = {soilTypeValue.toString(): 1};
                            }
                          }

                          if (data.containsKey('crop_type')) {
                            var cropTypeValue = data['crop_type'] as int;
                            if (parameterAverages.containsKey('crop_type')) {
                              parameterAverages['crop_type']!['sum'] += cropTypeValue.toDouble();
                              parameterAverages['crop_type']!['count']++;
                            } else {
                              parameterAverages['crop_type'] = {
                                'sum': cropTypeValue.toDouble(),
                                'count': 1,
                              };
                            }

                            if (majorityValues.containsKey('crop_type')) {
                              majorityValues['crop_type']![cropTypeValue.toString()] =
                                  (majorityValues['crop_type']![cropTypeValue.toString()] ?? 0) + 1;
                            } else {
                              majorityValues['crop_type'] = {cropTypeValue.toString(): 1};
                            }
                          }
                        }
                      }
                    });

                    if (parameterAverages.isEmpty) {
                      return Center(
                        child: Image.asset(
                          'lib/images/2000.jpg',
                          width: 350,
                          height: 350,
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: parameterAverages.length,
                        itemBuilder: (context, index) {
                          var parameter = parameterAverages.keys.elementAt(index);
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


                         if (parameter != 'soil_type' && parameter != 'crop_type') {
  dbRef
      .child(
          'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/$parameter')
      .set({
    'average': average,
    'unit': unit,
  });
}
                          
                          

                         if (parameter == 'soil_type' || parameter == 'crop_type') {
  var majorityValue = getMajorityValue(majorityValues[parameter]);
  var displayName = parameter == 'soil_type' ? getSoilType(int.parse(majorityValue)) : getCropType(int.parse(majorityValue));

  // Store averaged data


// Store majority values for soil_type and crop_type
if (parameter == 'soil_type' || parameter == 'crop_type') {
    var majorityValue = getMajorityValue(majorityValues[parameter]);
    var displayName = parameter == 'soil_type' ? getSoilType(int.parse(majorityValue)) : getCropType(int.parse(majorityValue));

    // Create a separate reference for majority values
    dbRef
        .child(
             'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/$parameter')
        .set({
      'majority_value': majorityValue,
      'display_name': displayName,
    });
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$displayName $unit',
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
} else {
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
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
                          }
                        },
                      );
                    }
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),



          
          
          
          
          
          
          //here
          
      Container(
  //decoration: BoxDecoration(
   // color: Color.fromARGB(255, 86, 243, 33),
  //  borderRadius: BorderRadius.circular(10),
  //),
  padding: EdgeInsets.all(16),
  child: Text(
    'Fertilizers Options',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Color.fromARGB(255, 44, 20, 152),
    ),
  ),
),

      



Container(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ElevatedButton(
        onPressed: () {
          callServerFunctionFerti(
          widget.plotId,
          widget.areaId,
          FirebaseAuth.instance.currentUser?.displayName ?? "",
          selectedDate.toUtc().millisecondsSinceEpoch.toString(),
        );
          setState(() {
            isButtonPressed = true;
          });
        },
         child: Text(
    'Complex Fertilizer',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
        
        
      ),
      if (isButtonPressed)
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 247, 144, 0),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(16),
          child: StreamBuilder(
            stream: dbRef.child(
                'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/u_fertilizer_quantity',
            ).onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data?.snapshot.value != null) {
                  var uammountValue = snapshot.data?.snapshot.value.toString();
                  return Text(
                    'Fertilizer - "$uammountValue".',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  );
                }
              }
              return CircularProgressIndicator();
            },
          ),
        ),
    ],
  ),
),


//npk

 Column(
  children: [

     ElevatedButton(
        onPressed: () {
           callServerFunctionFerti(
          widget.plotId,
          widget.areaId,
          FirebaseAuth.instance.currentUser?.displayName ?? "",
          selectedDate.toUtc().millisecondsSinceEpoch.toString(),
        );
          setState(() {
            isButtonPressed1 = true;
          });
        },
         child: Text(
    'Stright Fertilizer',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white,
    ),
  ),
      ),
   
    if (isButtonPressed1)
      StreamBuilder(
        stream: dbRef
          .child(
            'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/u_recommended_Phosphorous',
          )
          .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            // Check if the value is available
            if (snapshot.data?.snapshot.value != null) {
              var uammountValue = snapshot.data?.snapshot.value.toString();
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 247, 144, 0), // You can choose any background color you like
                      borderRadius: BorderRadius.circular(10), // Add rounded corners if desired
                    ),
                    padding: EdgeInsets.all(8), // Adjust padding as needed
                    child: Text(
                      "Phosphorus: '$uammountValue'",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Add spacing between elements
                  // Fetch and display 'u_recommended_Nitrogen'
                  StreamBuilder(
                    stream: dbRef
                      .child(
                        'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/u_recommended_Nitrogen',
                      )
                      .onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> nitroSnapshot) {
                      if (nitroSnapshot.hasData && nitroSnapshot.data?.snapshot.value != null) {
                        var nitroValue = nitroSnapshot.data?.snapshot.value.toString();
                        return Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 247, 144, 0), // You can choose any background color you like
                            borderRadius: BorderRadius.circular(10), // Add rounded corners if desired
                          ),
                          padding: EdgeInsets.all(8), // Adjust padding as needed
                          child: Text(
                            "Nitrogen: '$nitroValue'",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
                    },
                  ),
                  SizedBox(height: 10), // Add spacing between elements
                  // Fetch and display 'u_recommended_Pottasium'
                  StreamBuilder(
                    stream: dbRef
                      .child(
                        'averaged_data/${FirebaseAuth.instance.currentUser?.displayName}/Fertilizer Recomendation/${widget.areaId}/${widget.plotId}/u_recommended_Pottasium',
                      )
                      .onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> potaSnapshot) {
                      if (potaSnapshot.hasData && potaSnapshot.data?.snapshot.value != null) {
                        var potaValue = potaSnapshot.data?.snapshot.value.toString();
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.orange, // You can choose any background color you like
                            borderRadius: BorderRadius.circular(10), // Add rounded corners if desired
                          ),
                          padding: EdgeInsets.all(8), // Adjust padding as needed
                          child: Text(
                            "Potassium: '$potaValue'",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
                    },
                  ),
                ],
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


//herre














































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

 String getMajorityValue(Map<String, dynamic>? counts) {
  if (counts == null || counts.isEmpty) {
    return 'N/A';
  }

  Map<String, int> intCounts = {};

  counts.forEach((key, value) {
    if (value is int) {
      intCounts[key] = value;
    }
  });

  if (intCounts.isEmpty) {
    return 'N/A';
  }

  var majorityEntry = intCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
  return majorityEntry.key;
}

}

////////////////////////////////////////////////////////working///////////////////////////////////
/////////////////////////////////////////////a/////////////////////////////
///a///////////////////////////a/////////////////////////////a/////////////////////////////
///////a///////////////////////////////////////////a///////////////////////////////////////////a////////////////////////a/
///WORKING///////////////
///////////////
/////////////////UIIUUUIUIUIUIUIUI////////////////////////////////////
//////////////////////////
//////////////////////////////////
/////////