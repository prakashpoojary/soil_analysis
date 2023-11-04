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
    home: MySoilData3(),
    theme: ThemeData(
      fontFamily: 'Roboto', // Use a suitable font family
    ),
  ));
}

class MySoilData3 extends StatefulWidget {
  const MySoilData3({Key? key}) : super(key: key);

  @override
  State<MySoilData3> createState() => _MySoilData3State();
}

class _MySoilData3State extends State<MySoilData3> {
  final dbRef = FirebaseDatabase.instance.ref();
  double nitrogenValue = 0.0; // Store nitrogen value
  double phosphorusValue = 0.0; // Store phosphorus value
  double potassiumValue = 0.0; // Store potassium value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NPK"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 13, 13, 162),
                Color.fromARGB(255, 0, 1, 8),
              ], // Adjust gradient colors
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
                  // Extract NPK values
                  String? nitrogen = values['nitrogen'];
                  String? phosphorus = values['phosphorus'];
                  String? potassium = values['potassium'];

                  if (nitrogen != null) {
                    nitrogenValue = double.parse(nitrogen.split(" ")[0]);
                  }

                  if (phosphorus != null) {
                    phosphorusValue = double.parse(phosphorus.split(" ")[0]);
                  }

                  if (potassium != null) {
                    potassiumValue = double.parse(potassium.split(" ")[0]);
                  }

                  // Create data points
                  final List<DataPoint> dataPoints = [
                    DataPoint('Nitrogen', nitrogenValue),
                    DataPoint('Phosphorus', phosphorusValue),
                    DataPoint('Potassium', potassiumValue),
                  ];

                  return Column(
                    
                    children: [
                      // Display NPK values one by one with increased width
                      buildParameterCard("Nitrogen", "${nitrogenValue.toStringAsFixed(2)} mg/kg"),
                      buildParameterCard("Phosphorus", "${phosphorusValue.toStringAsFixed(2)} mg/kg"),
                      buildParameterCard("Potassium", "${potassiumValue.toStringAsFixed(2)} mg/kg"),
                      // Add a widget to display the real-time comparison graph
                     Container(
  height: 350, // Adjust the height as needed
  child: SfCircularChart(
    
    legend: Legend(
      isVisible: true,
      overflowMode: LegendItemOverflowMode.wrap,
      textStyle: TextStyle(fontSize: 16, color: Colors.white), // Make legend text white
      position: LegendPosition.bottom, // Move the legend to the bottom
    ),
    series: <PieSeries<DataPoint, String>>[
      PieSeries<DataPoint, String>(
        name: 'NPK Values',
        dataSource: dataPoints,
        xValueMapper: (data, _) => data.category,
        yValueMapper: (data, _) => data.value,
        dataLabelMapper: (DataPoint data, _) => '${data.value.toStringAsFixed(2)}',

        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(fontSize: 12, color: Colors.white), // Make data label text white
        ),
        // Apply styling to the pie segments with custom colors
        pointColorMapper: (DataPoint data, _) {
          switch (data.category) {
            case 'Nitrogen':
              return Colors.blue;
            case 'Phosphorus':
              return Colors.green;
            case 'Potassium':
              return Colors.orange;
            default:
              return Colors.grey;
          }
        },
        // Explode a segment for emphasis
        explode: false ,
        // Adjust the distance of the exploded segment
        explodeOffset: '10%',
      ),
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
}
