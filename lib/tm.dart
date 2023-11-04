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
    home: MySoilData4(),
    theme: ThemeData(
      fontFamily: 'Roboto', // Use a suitable font family
    ),
  ));
}

class MySoilData4 extends StatefulWidget {
  const MySoilData4({Key? key}) : super(key: key);

  @override
  State<MySoilData4> createState() => _MySoilData4State();
}

class _MySoilData4State extends State<MySoilData4> {
  final dbRef = FirebaseDatabase.instance.ref();
  double temperatureValue = 0.0; // Store temperature value
  double humidityValue = 0.0; // Store humidity value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tempareture & Humidity"),
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
                  // Extract Temperature and Humidity values
                  String? temperature = values['temperature'];
                  String? humidity = values['humidity'];

                  if (temperature != null) {
                    temperatureValue = double.parse(temperature.split(" ")[0]);
                  }

                  if (humidity != null) {
                    humidityValue = double.parse(humidity.split(" ")[0]);
                  }

                  // Create data points for Temperature and Humidity
                  final List<DataPoint> tempHumidityDataPoints = [
                    DataPoint('Temperature', temperatureValue),
                    DataPoint('Humidity', humidityValue),
                  ];

                  return Column(
                    children: [
                      // Display Temperature and Humidity values
                      buildParameterCard("Temperature", "${temperatureValue.toStringAsFixed(2)} °C"),
                      buildParameterCard("Humidity", "${humidityValue.toStringAsFixed(2)} %"),

                      // Add a widget to display the real-time comparison graph for Temperature and Humidity
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
                              name: 'Temperature & Humidity',
                              dataSource: tempHumidityDataPoints,
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
                                  case 'Temperature':
                                    return Colors.red;
                                  case 'Humidity':
                                    return Colors.yellow;
                                  default:
                                    return Colors.grey;
                                }
                              },
                              // Explode a segment for emphasis
                              explode: false,
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
