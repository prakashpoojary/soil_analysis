import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


void main() {
  runApp(MaterialApp(
    home: MySoilData2(),
    theme: ThemeData(
      fontFamily: 'Roboto', // Use a suitable font family
    ),
  ));
}

class MySoilData2 extends StatefulWidget {
  const MySoilData2({Key? key}) : super(key: key);

  @override
  State<MySoilData2> createState() => _MySoilData2State();
}

class _MySoilData2State extends State<MySoilData2> {
  final dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quick Data Access"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 9, 9, 10), Color.fromARGB(255, 0, 1, 8)], // Adjust gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        // Set the background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/images/black.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: StreamBuilder(
          stream: dbRef.child('sensor_data').onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasData) {
              DataSnapshot? dataValues = snapshot.data?.snapshot;
              Map<dynamic, dynamic>? values =
                  dataValues?.value as Map<dynamic, dynamic>?;
              if (values != null && values.isNotEmpty) {
                return ListView.builder(
                  itemCount: values.keys.length,
                  itemBuilder: (BuildContext context, int index) {
                    String parameter = values.keys.toList()[index].toString();
                    String value = values.values.toList()[index].toString();
                    return buildParameterCard(parameter, value);
                  },
                );
              }
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }

Widget buildParameterCard(String parameter, String value) {
  double numericValue = double.parse(value.split(" ")[0]);
  double maxValue;

  switch (parameter) {
    case "ec":
      maxValue = 500;
      break;
    case "humidity":
    case "moisture":
    case "nitrogen":
    case "phosphorus":
    case "potassium":
      maxValue = 100;
      break;
    case "ph":
      maxValue = 14;
      break;
    case "temperature":
      maxValue = 45;
      break;
    default:
      maxValue = 100; // Default maximum value
  }

  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 36, 36, 36),
          Color.fromARGB(255, 18, 18, 18),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 15,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parameter,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: maxValue,
                showLabels: false,
                showTicks: false,
                radiusFactor: 0.8,
                pointers: <GaugePointer>[
                  RangePointer(
                    value: numericValue,
                    cornerStyle: CornerStyle.bothCurve,
                    width: 0.15,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.white,
                    gradient: const SweepGradient(colors: <Color>[
                      Color.fromARGB(255, 216, 56, 227),
                      Color.fromARGB(255, 80, 61, 226),
                    ], stops: <double>[
                      0.25,
                      0.75,
                    ]),
                  ),
                  RangePointer(
                    value: maxValue,
                    cornerStyle: CornerStyle.bothCurve,
                    width: 0.15,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: Colors.transparent, // Transparent color for the colorless range
                    gradient: const SweepGradient(colors: <Color>[
                      Colors.transparent,
                      Colors.transparent,
                    ], stops: <double>[
                      0.25,
                      0.75,
                    ]),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              numericValue.toStringAsFixed(2), // Display the current value
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '/ ' + maxValue.toString(), // Display the maximum value
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    positionFactor: 0.1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}




}

