import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;
import 'package:SoilAnalysis/area.dart'; // Import the MyArea class from the appropriate location
import 'package:SoilAnalysis/soil.dart';






enum StyleOption {
  Default,
  RadialGauge,
}

class MySoilData1 extends StatefulWidget {
  const MySoilData1({Key? key}) : super(key: key);

  

  @override
  State<MySoilData1> createState() => _MySoilData1State();
}

class _MySoilData1State extends State<MySoilData1> {
  final dbRef = FirebaseDatabase.instance.ref();
  Map<dynamic, dynamic>? values1;
  StyleOption currentStyle = StyleOption.Default;
  String selectedCropType = 'Wheat'; // Default crop type
  String selectedSoilType = 'Loamy'; // Default soil type
  
  Future<void> callServerFunction(String plotId,String areaId,String userName,String timestamp,String N,String P,String K) async {
                          final url = 'https://mlbackend--croprecommendat.repl.co/fertilizer_function';

                        final headers = {'Content-Type': 'application/json'};
                        final plot = plotId;
                        final area = areaId;
                        final user = userName;
                        final userN = N;
                        final userP = P;
                        final userK = K;
                        final requestdata = {'user': user, 'area': area, 'plot': plot,'timestamp':timestamp,'userN':userN,'userP':userP,'userK':userK};

                        final response = await http.post(Uri.parse(url),headers: headers, body: jsonEncode(requestdata));

                        if (response.statusCode == 200) {
                        final result = jsonDecode(response.body)['result'];
                          print('Result from server: $result');
                        } else {
                        print('Failed to call server function');
                        }
                        }

 Future<void> callServerFunctioncrop(String plotId,String areaId,String userName,String timestamp) async {
                          final url = 'https://mlbackend--croprecommendat.repl.co/crop_function';

                        final headers = {'Content-Type': 'application/json'};
                        final plot = plotId;
                        final area = areaId;
                        final user = userName;
                        final requestdata = {'user': user, 'area': area, 'plot': plot,'timestamp':timestamp};

                        final response = await http.post(Uri.parse(url),headers: headers, body: jsonEncode(requestdata));

                        if (response.statusCode == 200) {
                        final result = jsonDecode(response.body)['result'];
                          print('Result from server: $result');
                        } else {
                        print('Failed to call server function');
                        }
                        }

  Map<String, int> cropItems = {
  'Wheat': 10,
  'Maize': 3,
  'Cotton': 1,
  'Tobacco': 9,
  'Paddy': 6,
  'Barley': 0,
  'Sugarcane': 8,
  'Millets': 4,
  'Oil seeds': 5,
  'Groud Nuts': 2,
};

Map<String, int> soilItems = {
  'Loamy': 2,
  'Clayey': 1,
  'Sandy': 4,
  'Black': 0,
  'Red': 3,
};


  @override
  void initState() {
    super.initState();
    dbRef.child('sensor_data').onValue.listen((event) {
      DataSnapshot? dataValues = event.snapshot;
      if (dataValues?.value is Map<dynamic, dynamic>) {
        setState(() {
          values1 = dataValues?.value as Map<dynamic, dynamic>;
        });
      }
    });
  }

  //////////////////////////////////////////////////////////////workinggggggggggggggggggggggggggggggggggggggggg

  
  Widget buildParameterCard(String parameter, String value) {
    Widget cardContent;

    switch (currentStyle) {
      case StyleOption.Default:
        cardContent = Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    parameter,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case StyleOption.RadialGauge:
        cardContent = Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    parameter,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            buildRadialGauge(parameter, double.parse(value.replaceAll(RegExp('[^0-9.]'), ''))),
          ],
        );
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.transparent, // Set to transparent to apply gradient background
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [ Colors.blue,
                Color.fromARGB(255, 4, 2, 1),], // Gradient colors
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: cardContent,
      ),
    );
  }

  Widget buildRadialGauge(String parameter, double value) {
    double minValue = 0;
    double maxValue;

    switch (parameter.toLowerCase()) {
      case 'humidity':
      case 'moisture':
        maxValue = 100;
        break;
      case 'ec':
        maxValue = 500;
        break;
      case 'nitrogen':
      case 'phosphorus':
      case 'potassium':
        maxValue = 125;
        break;
      case 'ph':
        maxValue = 14;
        break;
      case 'temperature':
        maxValue = 50;
        break;
      default:
        maxValue = 100;
        break;
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: minValue,
          maximum: maxValue,
          ranges: <GaugeRange>[
            GaugeRange(startValue: minValue, endValue: (maxValue - minValue) * 0.3, color: Colors.red),
            GaugeRange(startValue: (maxValue - minValue) * 0.3, endValue: (maxValue - minValue) * 0.7, color: Colors.yellow),
            GaugeRange(startValue: (maxValue - minValue) * 0.7, endValue: maxValue, color: Colors.green),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: value),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '$value',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }

  void showStyleSelectionPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  setState(() {
                    currentStyle = StyleOption.Default;
                  });
                  Navigator.pop(context);
                },
                title: Text("Default Style"),
                leading: currentStyle == StyleOption.Default ? Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
              ),
              ListTile(
                onTap: () {
                  setState(() {
                    currentStyle = StyleOption.RadialGauge;
                  });
                  Navigator.pop(context);
                },
                title: Text("Radial Gauge Style"),
                leading: currentStyle == StyleOption.RadialGauge ? Icon(Icons.check_circle) : Icon(Icons.circle_outlined),
              ),
            ],
          ),
        );
      },
    );
  }

 String getCropTypeString(String selectedCropType) {
  int cropTypeIndex = cropItems[selectedCropType] ?? -1; // Default to -1 if not found
  return cropTypeIndex != -1 ? selectedCropType : 'Unknown';
}

String getSoilTypeString(String selectedSoilType) {
  int soilTypeIndex = soilItems[selectedSoilType] ?? -1; // Default to -1 if not found
  return soilTypeIndex != -1 ? selectedSoilType : 'Unknown';
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: false,
        title: Row(
          children: [
            Icon(
              Icons.eco,
              color: Colors.white,
            ),
            SizedBox(width: 5),
            Text(
              "Data Analysis",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showStyleSelectionPopup(context);
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.all(25),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 15),



Container(
  padding: EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [ Colors.blue,
                Color.fromARGB(255, 4, 2, 1),],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    "Crop Type", // Display "Crop Type" here
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 18,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),

      SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCropType,
            onChanged: (String? newValue) {
              setState(() {
                selectedCropType = newValue!;
              });
            },
            dropdownColor: Colors.white,
            elevation: 5,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
            items: [
  ...cropItems.keys.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }).toList(),
  DropdownMenuItem<String>(
    value: 'Other',
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        'Other',
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Montserrat',
          color: Colors.blue, // Customize the color for the 'Other' option
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
],

          ),
        ),
      ),
      SizedBox(height: 20),
      Container(
  width: double.infinity,
  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [ Colors.blue,
                Color.fromARGB(255, 4, 2, 1),],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(
    "Soil Type", // Display "Soil Type" here
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 18,
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
),

      SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedSoilType,
            onChanged: (String? newValue) {
              setState(() {
                selectedSoilType = newValue!;
              });
            },
            dropdownColor: Colors.white,
            elevation: 5,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.black87),
            items: [
  ...soilItems.keys.map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }).toList(),
  DropdownMenuItem<String>(
    value: 'Other',
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Text(
        'Other',
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Montserrat',
          color: Colors.blue, // Customize the color for the 'Other' option
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
],

          ),
        ),
      ),
    ],
  ),
),











            Expanded(
              child: StreamBuilder(
                stream: dbRef.child('sensor_data').onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData) {
                    DataSnapshot? dataValues = snapshot.data?.snapshot;
                    if (dataValues?.value is Map<dynamic, dynamic>) {
                      values1 = dataValues?.value as Map<dynamic, dynamic>;
                    }
                    Map<dynamic, dynamic>? values = dataValues?.value as Map?;
                    if (values != null && values.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: values.keys.length,
                        itemBuilder: (BuildContext context, int index) {
                          String parameter = values.keys.toList()[index].toString();
                          String value = values.values.toList()[index].toString();
                          return buildParameterCard(parameter, value);
                        },
                      );
                    }
                    return CircularProgressIndicator();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return Text('No data');
                  }
                },
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child:
                
                
                 ElevatedButton(
  onPressed: () async {
    if (values1 != null && values1!.isNotEmpty) {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.displayName != null) {
        final String userName = user.displayName!;
        final String areaId = MyArea.area;
        final String plotId = MyArea.plot;
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        final dbPathCrop = 'saved_data/$userName/Crop Recomendations/$areaId/$plotId/${DateTime.now().millisecondsSinceEpoch}';
        final dbPathFertilizer = 'saved_data/$userName/Fertilizer Recomendation/$areaId/$plotId/${DateTime.now().millisecondsSinceEpoch}';

        final dbRefCrop = FirebaseDatabase.instance.reference().child(dbPathCrop);
        final dbRefFertilizer = FirebaseDatabase.instance.reference().child(dbPathFertilizer);

        int? cropValue = cropItems[selectedCropType];
        int? soilValue = soilItems[selectedSoilType];

        // Filter values1 based on checked cards
        final filteredValues = values1!.entries
           
            .fold({}, (result, entry) {
          // Exclude 'crop_type' and 'soil_type' from the filtered values
          if (entry.key != 'crop_type' && entry.key != 'soil_type') {
            result[entry.key] = entry.value;
          }
          return result;
        });

        // Save to Crop Recomendations path (without crop_type and soil_type)
        await dbRefCrop.set({
          'data': filteredValues,
          'timestamp': timestamp,
        });

        // Save to Fertilizer Recomendation path (including crop_type and soil_type)
        await dbRefFertilizer.set({
          'data': {...filteredValues, 'crop_type': cropValue, 'soil_type': soilValue},
          'timestamp': timestamp,
        });

        final String userN = " "; // Replace with actual value
        final String userP = " "; // Replace with actual value
        final String UserK = " "; // Replace with actual value
        callServerFunction(plotId, areaId, userName, timestamp, userN, userP, UserK);
        
        // Call the missing callServerFunctioncrop here
        callServerFunctioncrop(plotId, areaId, userName, timestamp);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Sensor data has been saved successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 36, 186, 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Handle the case where user or user's display name is null
        // Show an error message or take appropriate action
      }
    }
  },
  child: Text(
    "SAVE",
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'Montserrat',
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 36, 186, 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5.0),
    ),
  ),
),





              ),
            ),
          ],
        ),
      ),

    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MySoilData1(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      fontFamily: 'Montserrat',
    ),
  ));
}
