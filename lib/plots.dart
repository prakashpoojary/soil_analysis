import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SoilAnalysis/area.dart';

class MyPlots extends StatefulWidget {
  const MyPlots({Key? key}) : super(key: key);

  @override
  State<MyPlots> createState() => _MyPlotsState();
}

class _MyPlotsState extends State<MyPlots> {
  var plotCount = 5;
  double plusButtonScale = 1.0;
  double minusButtonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPlotCount(); // Load the plot count when the widget initializes
  }

  // Load the plot count from SharedPreferences
  _loadPlotCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      plotCount = prefs.getInt('plotCount') ?? 5; // Default to 5 if not found
    });
  }

  // Save the plot count to SharedPreferences
  _savePlotCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('plotCount', plotCount);
  }

  void increasePlotCount() {
    setState(() {
      plotCount = plotCount + 1;
      plusButtonScale = 1.1;
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          plusButtonScale = 1.0;
          _savePlotCount(); // Save the plot count when it changes
        });
      });
    });
  }

  void decreasePlotCount() {
    setState(() {
      if (plotCount > 1) {
        plotCount = plotCount - 1;
        minusButtonScale = 1.1;
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            minusButtonScale = 1.0;
            _savePlotCount(); // Save the plot count when it changes
          });
        });
      }
    });
  }


  plotContainer(index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            MyArea.plot = "Plot ${index + 1}";
            Navigator.pushNamed(context, "soil1");
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(0, 0, 0, 0), //box shadow
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
             height: 110,
                          width: MediaQuery.of(context).size.width / 2 - 16,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),], //madyad color
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Plot ${index + 1}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
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
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Icon(Icons.home),
          SizedBox(width: 5),
          Text(
            "Choose Plot",
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: increasePlotCount,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(0, 250, 242, 242).withOpacity(0),
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            transform: Matrix4.identity()..scale(plusButtonScale),
            child: Center(
              child: Text(
                "+",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: decreasePlotCount,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(0, 254, 254, 254).withOpacity(0),
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            transform: Matrix4.identity()..scale(minusButtonScale),
            child: Center(
              child: Text(
                "-",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)], // Gradient colors for outside the margin
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
        colors: [ Color.fromARGB(255, 255, 253, 253),
                Color.fromARGB(0, 255, 254, 254),], // Drawer Gradient colors
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ), // White color inside the margin
            border: Border.all(color: Color.fromARGB(26, 0, 0, 0)),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 1,
              ),
              itemCount: plotCount,
              itemBuilder: (context, index) {
                return plotContainer(index);
              },
            ),
          ),
        ),
      ),
    ),
  );
}

}



void main() {
  runApp(MaterialApp(
    home: MyPlots(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      fontFamily: 'Montserrat',
    ),
  ));
}

//plot