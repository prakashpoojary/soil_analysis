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
    home: MySoilData5(),
    theme: ThemeData(
      fontFamily: 'Roboto', // Use a suitable font family
    ),
  ));
}

class MySoilData5 extends StatefulWidget {
  const MySoilData5({Key? key}) : super(key: key);

  @override
  State<MySoilData5> createState() => _MySoilData5State();
}

class _MySoilData5State extends State<MySoilData5> {
  final dbRef = FirebaseDatabase.instance.ref();
  double pHValue = 14.0; // Set the y-axis value to 14 initially

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("potential of Hydrogen"),
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
                  // Extract pH value
                  String? pH = values['ph'];

                  if (pH != null) {
                    pHValue = double.tryParse(pH.split(" ")[0]) ?? 0.0;
                  }

                  // Create data point for pH
                  final List<DataPoint> pHDataPoints = [
                    DataPoint('pH', pHValue),
                  ];

                  Color barColor = Colors.green; // Default color is green
                  String pHLabel = 'Medium'; // Default label is Medium

                  if (pHValue < 6.5) {
                    barColor = Colors.yellow; // Change color to yellow if pH is below 6.5
                    pHLabel = 'Low'; // Change label to Low
                  } else if (pHValue > 8.5) {
                    barColor = Colors.red; // Change color to red if pH is above 8.5
                    pHLabel = 'High'; // Change label to High
                  }

                  return Column(
                    children: [
                      // Display pH value
                      buildParameterCard("pH", "${pHValue.toStringAsFixed(2)}"),

                      // Add a chart to display the pH value (e.g., stacked column chart)
                      Container(
                        height: 350, // Adjust the height as needed
                        child: SfCartesianChart(
                          plotAreaBackgroundColor: Colors.transparent,
                          primaryXAxis: CategoryAxis(
                            majorGridLines: MajorGridLines(width: 0),
                            axisLine: AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: AxisLine(width: 0),
                            labelStyle: TextStyle(color: Colors.white),
                            majorTickLines: MajorTickLines(size: 0),
                            maximum: 14, // Set the maximum y-axis value to 14
                            interval: 2, // Set the interval as needed
                          ),
                          series: <StackedColumnSeries<DataPoint, String>>[
                            StackedColumnSeries<DataPoint, String>(
                              dataSource: pHDataPoints,
                              xValueMapper: (data, _) => data.category,
                              yValueMapper: (data, _) => data.value,
                              // Customize the appearance of the stacked column chart
                              borderRadius: BorderRadius.circular(10),
                              color: barColor, // Set the bar color based on pH value
                              dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          // Adjust the margins
                          margin: EdgeInsets.all(10),
                        ),
                      ),
                      // Display pH level label
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildPhLabel('Low', Colors.yellow),
                            buildPhLabel('Medium', Colors.green),
                            buildPhLabel('High', Colors.red),
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

  Widget buildPhLabel(String label, Color color) {
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
