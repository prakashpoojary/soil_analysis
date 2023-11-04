import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataPoint {
  final String category;
  final double value;

  DataPoint(this.category, this.value);
}

void main() {
  runApp(MaterialApp(
    home: MySoilData7(),
    theme: ThemeData(
      fontFamily: 'Roboto', // Use a suitable font family
    ),
  ));
}

class MySoilData7 extends StatefulWidget {
  const MySoilData7({Key? key}) : super(key: key);

  @override
  State<MySoilData7> createState() => _MySoilData7State();
}

class _MySoilData7State extends State<MySoilData7> {
  final dbRef = FirebaseDatabase.instance.ref();
  double moistureValue = 0.0; // Store Moisture value

  Color getBarColor(double value) {
    if (value < 30) {
      return Colors.yellow;
    } else if (value >= 30 && value <= 70) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String getMoistureLabel(double value) {
    if (value < 30) {
      return 'Low';
    } else if (value >= 30 && value <= 70) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Moisture"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 13, 13, 162),
                Color.fromARGB(255, 0, 1, 8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 0, 0),
                Color.fromARGB(255, 13, 13, 162),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(20.0),
          child: StreamBuilder(
            stream: dbRef.child('sensor_data').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData) {
                DataSnapshot? dataValues = snapshot.data?.snapshot;
                Map<dynamic, dynamic>? values =
                    dataValues?.value as Map<dynamic, dynamic>?;
                if (values != null && values.isNotEmpty) {
                  // Extract Moisture value
                  String? moisture = values['moisture'];

                  if (moisture != null) {
                    moistureValue = double.tryParse(moisture.split(" ")[0]) ?? 0.0;
                  }

                  // Create data point for Moisture
                  final List<DataPoint> moistureDataPoints = [
                    DataPoint('Moisture', moistureValue),
                  ];

                  return Column(
                    children: [
                      // Display Moisture value
                      buildParameterCard("Moisture", "${moistureValue.toStringAsFixed(2)}"),

                      // Add a chart to display the Moisture value (stacked column chart)
                      Container(
                        height: 350, // Adjust the height as needed
                        child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          primaryYAxis: NumericAxis(),
                          series: <StackedColumnSeries<DataPoint, String>>[
                            StackedColumnSeries<DataPoint, String>(
                              dataSource: moistureDataPoints,
                              xValueMapper: (data, _) => data.category,
                              yValueMapper: (data, _) => data.value,
                              // Customize the appearance of the stacked column chart
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              // Set the stacking group for the series
                              groupName: 'Moisture',
                              color: getBarColor(moistureValue), // Set bar color based on moisture value
                            ),
                          ],
                        ),
                      ),
                      // Display moisture level label
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildMoistureLabel('Low', Colors.yellow),
                            buildMoistureLabel('Medium', Colors.green),
                            buildMoistureLabel('High', Colors.red),
                          ],
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget buildParameterCard(String parameter, String value, {double width = 350.0}) {
    return Container(
      width: width, // Adjust the width as needed
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 13, 13, 162),
            Color.fromARGB(255, 0, 0, 0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            parameter,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoistureLabel(String label, Color color) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
