import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';




class MyArea extends StatefulWidget {
  const MyArea({Key? key}) : super(key: key);
  

  static String fieldName = ""; // Added to store the field name
  static List<String> areaNames = [];
  static String area = "";
  static String plot = "";
  
  
  @override
  State<MyArea> createState() => _MyAreaState();
  
}

/////////////////////////////////////Workig////////////////////////////////////
/////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////A

class _MyAreaState extends State<MyArea> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  double plusButtonScale = 1.0;
  double minusButtonScale = 1.0;
  SharedPreferences? _prefs; // Add this variable to store SharedPreferences
  bool _isInitialized = false; // Add a flag to check if SharedPreferences is initialized
  
 // Modify the functions that update data to call _saveData
  void updateAreaNames() {
    setState(() {
      MyArea.areaNames = MyArea.areaNames.map((area) => " $area").toList();
      _saveData(); // Save data when updating area names
    });
  }

  @override
  void initState() {
    super.initState();
    _initSharedPreferences(); 
    _saveData();// Initialize SharedPreferences
    // Call the function to show the field name dialog after a delay
    Future.delayed(Duration.zero, () {
      
      _saveData();
    });
  }

  void _initSharedPreferences() async {
  if (!_isInitialized) {
    _prefs = await SharedPreferences.getInstance();
    MyArea.fieldName = _prefs!.getString('fieldName') ?? ''; // Retrieve field name
    MyArea.areaNames = _prefs!.getStringList('areaNames') ?? []; // Retrieve area names
    _isInitialized = true;
    _saveData(); // Set the flag to true after initialization
  }
}


  Future<void> _saveData() async {
  await _prefs?.setString('fieldName', MyArea.fieldName);
  await _prefs?.setStringList('areaNames', MyArea.areaNames);
}


  
  // Update the field name
  void setFieldName(String newName) {
    setState(() {
      MyArea.fieldName = newName;
      _saveData(); // Save the updated field name
    });
  }

  // Function to show the field name dialog
  // Function to show the field name dialog
  // Modify the showFieldNameDialog function to initialize areaNames with default areas
void showFieldNameDialog() {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController();
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Color.fromARGB(255, 255, 253, 255),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New Field",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter field name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      MyArea.fieldName = controller.text;
                      MyArea.areaNames.clear(); // Clear the previous area names
                      MyArea.areaNames.addAll(["Acre 1", "Acre 2", "Acre 3"]); // Initialize with default areas
                      updateAreaNames();
                      _saveData();
                       // Call updateAreaNames to update the UI
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

    void increaseAreaCount() {
    setState(() {
      final newIndex = MyArea.areaNames.length;
      MyArea.areaNames.add("Acre ${newIndex + 1}");
      plusButtonScale = 1.1;
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          plusButtonScale = 1.0;
        });
      });
      _saveData(); // Save data when increasing area count
    });
  }

  void decreaseAreaCount() {
    setState(() {
      if (MyArea.areaNames.length > 1) {
        MyArea.areaNames.removeLast();
        minusButtonScale = 1.1;
        Future.delayed(Duration(milliseconds: 100), () {
          setState(() {
            minusButtonScale = 1.0;
          });
        });
        _saveData(); // Save data when decreasing area count
      }
    });
  }

 void _showRenameDialog(int index) {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController controller = TextEditingController(text: MyArea.areaNames[index]);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Color.fromARGB(255, 255, 255, 255), // Stylish background color for the dialog
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rename Area",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0), // Stylish text color for dialog title
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter new name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0), // Stylish text color for Cancel button
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      String newName = controller.text;
                      if (MyArea.areaNames.contains(newName)) {
                        // Check if the new name already exists
                        // Display a styled warning dialog with a warning symbol
                       showDialog(
  context: context,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.transparent, // Make the background transparent
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white, // Background color of the dialog
          boxShadow: [
           
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.red, // Header background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Name Already Exists",
                    style: TextStyle(
                      color: Colors.white, // Title text color
                      fontSize: 20.0, // Title font size
                      fontWeight: FontWeight.bold, // Title font weight
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "This name already exists. Please choose a different name.",
                style: TextStyle(
                  fontSize: 16.0, // Content font size
                  color: Colors.black, // Content text color
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Button background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white, // Button text color
                    fontSize: 16.0, // Button font size
                    fontWeight: FontWeight.bold, // Button font weight
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);



                      } else {
                        setState(() {
                          MyArea.areaNames[index] = newName;
                        });
                        _saveData(); // Save data when renaming
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white, // Stylish text color for Save button
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 4, 2, 1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  elevation: 0,
  centerTitle: false,
  title: Row(
    children: [
      Icon(Icons.location_on),
      SizedBox(width: 5),
      Text(
        "Choose Acre",
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.add_card), // You can choose any icon you like
      onPressed: () {
        showFieldNameDialog();
      },
    ),
  ],
),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: increaseAreaCount,
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
                    color: Color.fromARGB(0, 255, 253, 253).withOpacity(0),
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
            onTap: decreaseAreaCount,
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
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 0),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color.fromARGB(255, 255, 255, 255)),//border
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: MyArea.areaNames.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          _showRenameDialog(index);
                        },
                       onTap: () {
  setState(() {
    MyArea.area = "${MyArea.fieldName}: ${MyArea.areaNames[index].replaceFirst("${MyArea.fieldName}: ", "")}";
    MyArea.plot = "Plot ${index + 1}";
  });
  Navigator.pushNamed(context, "plot");
},

                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0), //box shadow
                                blurRadius: 10.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          height: 120,
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [ Color(0xFFFFA726),
                                            Color(0xFFFF7043),], // Stylish background color for field name
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    MyArea.fieldName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: const Color.fromARGB(255, 246, 246, 246),
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),], // Stylish background color for area name
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    MyArea.areaNames[index].replaceFirst("${MyArea.fieldName}: ", ""),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Montserrat',
                                      color: const Color.fromARGB(255, 246, 246, 246),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
    home: MyArea(),
    theme: ThemeData(
      primarySwatch: Colors.teal,
      fontFamily: 'Montserrat',
    ),
  ));
}


//updated