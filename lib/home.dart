import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'dart:async';
import 'package:analog_clock/analog_clock.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:SoilAnalysis/notification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Import the dart:io library for File class
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart'; 
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
// Import image_cropper package

void main() {
  runApp(MaterialApp(
    home: MyHome(),
    theme: ThemeData(
      primarySwatch: Colors.purple,
      fontFamily: 'Montserrat',
    ),
  ));
}


class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}


class _MyHomeState extends State<MyHome> {
  String weatherInfo = ''; // Store weather information
  bool _isLoading = true;
  String temperature = ''; // Store temperature
  String condition = ''; // Store weather condition
  String windSpeed = ''; // Store wind speed
  String humidity = ''; 
  String day = ''; 
  String last = ''; 
  
  


 
   
  final FirebaseAuth _auth = FirebaseAuth.instance;
 final ImageCropper _imageCropper = ImageCropper();
 PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> imagePaths = [
  'lib/images/50.png',
  'lib/images/12.png',
  'lib/images/13.png',
  'lib/images/14.png',
  'lib/images/15.png',
  'lib/images/16.png',
  'lib/images/17.png',
  'lib/images/18.png',
  'lib/images/19.png',
  'lib/images/20.png',
  'lib/images/21.png',
  'lib/images/22.png',
  'lib/images/23.png',
  'lib/images/24.png',
  'lib/images/25.png',
  // Replace with your image paths
];



  Future<void> _fetchSoilRelatedNews() async {
  final apiKey = 'ac21b1d372554f97b12a2dcaafd54be6';
  final keywords = [
   'crops', 'cultivate', 'soil analysis', 'farming'
  ];
  final query = keywords.join(' OR ');
  final url = 'https://newsapi.org/v2/everything?q=$query&apiKey=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final articles = data['articles'] as List<dynamic>;
    

    if (articles.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationScreen(articles: articles),
        ),
      );
    }
  }
}

  User? _user;
  Timer? _timeoutTimer;
  int _timeoutDurationInSeconds = 3600;

  late Timer _timeUpdateTimer;
  
 Future<void> _cropImage() async {
  CroppedFile? cropped = await _imageCropper.cropImage(
    sourcePath: _pickedImage!.path,
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 100,
    maxHeight: 800,
    maxWidth: 800,
    compressFormat: ImageCompressFormat.jpg,
  );

 if (cropped != null) {
    final appDocDir = await getApplicationDocumentsDirectory();
    final userId = _user?.uid ?? 'guest'; // Use the user's UID or 'guest' if not authenticated
    final fileName = '$userId-cropped_image.jpg'; // Modify the file name

    final filePath = '${appDocDir.path}/$fileName';

    final croppedFile = File(cropped.path);
    await croppedFile.rename(filePath);

    setState(() {
      _pickedImage = File(filePath);
    });
  }
}


Future<void> loadPersistedImage() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final userId = _user?.uid ?? 'guest'; // Use the user's UID or 'guest' if not authenticated
  final fileName = '$userId-cropped_image.jpg'; // Modify the file name
  final filePath = '${appDocDir.path}/$fileName';
  final file = File(filePath);

  if (await file.exists()) {
    setState(() {
      _pickedImage = file;
    });
  }
}

void removeProfilePicture() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final userId = _user?.uid ?? 'guest'; // Use the user's UID or 'guest' if not authenticated
  final croppedFileName = '$userId-cropped_image.jpg'; // Modify the cropped file name
  final fullFileName = 'my_image.jpg'; // Modify the full image file name

  final croppedFilePath = '${appDocDir.path}/$croppedFileName';
  final fullFilePath = '${appDocDir.path}/$fullFileName';

  final croppedFile = File(croppedFilePath);
  final fullImageFile = File(fullFilePath);

  if (await croppedFile.exists()) {
    await croppedFile.delete();
  }

  if (await fullImageFile.exists()) {
    await fullImageFile.delete();
  }

  setState(() {
    _pickedImage = null;
  });
}

  
  

Future<void> saveImage(File imageFile, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      await imageFile.copy(filePath);
    } catch (e) {
      print('Error saving image: $e');
    }
  }



Future<File?> loadImage(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);

      if (await file.exists()) {
        return file;
      } else {
        return null; // Image doesn't exist
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }


Future<void> handleImageSelection() async {
  final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    final fileName = 'my_image.jpg';
    final imageFile = File(pickedImage.path);

    await saveImage(imageFile, fileName);
    print('Image saved successfully.');

    // To load the image later:
    final loadedImage = await loadImage(fileName);
    if (loadedImage != null) {
      setState(() {
        _pickedImage = File(loadedImage.path);
      });
      print('Image loaded successfully.');
      // You can display or use the loaded image as needed.
    } else {
      print('Image not found.');
    }
  }
}

void _openImagePicker() async {
  final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    // Handle the selected image here
    // You can save it locally or perform any other actions you need.
  }
}


  @override
  void initState()
  
  
   {
    super.initState();
    // Automatically change images every 3 seconds
    Timer.periodic(Duration(seconds: 20), (Timer timer) {
      _currentPage = (_currentPage + 1) % imagePaths.length;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
     
     fetchWeather();
    
    _user = _auth.currentUser;
    loadProfilePicture();
     loadPersistedImage();
    
    _resetTimeoutTimer();
    
    _startUpdatingTime();
    
}

//Weather 


Future<void> fetchWeather() async {
    final apiKey = '16d7299700af45beadf121001231209';
    final city = 'Udupi'; // Replace with your city name
    final apiUrl = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city'; //weather api here

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        temperature = '${jsonData['current']['temp_c']}°C';
        condition = jsonData['current']['condition']['text'];
        windSpeed = '${jsonData['current']['wind_kph']} km/h';
        humidity = '${jsonData['current']['humidity']} %';
        day = '${jsonData['current']['is_day']}';
        last = '${jsonData['current']['pressure_mb']}';
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          temperature = 'Failed to fetch';
          condition = 'weather data';
          windSpeed = '';
          _isLoading = false;
        });
      }
    } catch (e) {
    setState(() {
        temperature = 'Failed to fetch';
        condition = 'weather data';
        windSpeed = '';
        _isLoading = false;
      });
    }
  }
  

 Future<void> loadProfilePicture() async {
  final fileName = 'my_image.jpg';
  final loadedImage = await loadImage(fileName);
  if (loadedImage != null) {
    setState(() {
      _pickedImage = loadedImage;
    });
  }
}

File? _pickedImage;

  @override
  void dispose() {
    _pageController.dispose();
    _timeoutTimer?.cancel();
    _timeUpdateTimer.cancel();
    super.dispose();
    
  }

  void _startUpdatingTime() {/////////////
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _selectedTime = TimeOfDay.now();
      });
    });
  }

  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(seconds: _timeoutDurationInSeconds), _handleTimeout);
  }

  void _handleTimeout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Session Timeout'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_off,
                color: Colors.red,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                'Your session has timed out due to inactivity.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _signOut();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetTimeoutTimer();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _selectDate() async {
    _resetTimeoutTimer();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _selectTime(BuildContext context) async {
    _resetTimeoutTimer();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBodyBehindAppBar: false,
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(57), // Adjust the height as needed
      child: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Icon(
              Icons.eco,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              "SOIL ANALYSIS",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(255, 10, 11, 61)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _fetchSoilRelatedNews,
          ),
          // Add other action buttons as needed
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), // Adjust the height as needed
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align to the left
            children: [
              
            ],
          ),
          
        ),
        
      ),
      
    ),
    
    // Your remaining widget tree...
  


  
  

  
  drawer: Drawer(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Color.fromARGB(255, 4, 2, 1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 150, // Set the height for your image container
          child: Image.asset(
            'lib/images/400.jpeg', // Add the image path here
            fit: BoxFit.cover, // Fit the image within the container
          ),
        ),
        
        // Added screens with navigation
        
        ListTile(
          onTap: () {
            Navigator.of(context).pop(); // Close the drawer
            // Navigate to 'npk' screen
            Navigator.pushNamed(context, 'npk');
          },
          leading: Icon(
            Icons.dashboard,
            color: Colors.white,
          ),
          title: Text(
            'NPK',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop(); // Close the drawer
            // Navigate to 'tm' screen
            Navigator.pushNamed(context, 'tm');
          },
          leading: Icon(
            Icons.dashboard,
            color: Colors.white,
          ),
          title: Text(
            'Temp & Hum',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  // Navigate to 'ph' screen
                  Navigator.pushNamed(context, 'ph');
                },
                leading: Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                title: Text(
                  'potential of Hydrogen',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  // Navigate to 'ec' screen
                  Navigator.pushNamed(context, 'ec');
                },
                leading: Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                title: Text(
                  'Electrical Conductivity',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  // Navigate to 'moisture' screen
                  Navigator.pushNamed(context, 'moisture');
                },
                leading: Icon(
                  Icons.dashboard,
                  color: Colors.white,
                ),
                title: Text(
                  'Moisture',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
             
         ListTile(
            onTap: () async {
              Navigator.of(context).pop(); // Close the drawer

              // Check if an image is already picked
              if (_pickedImage != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: null,
                      contentPadding: EdgeInsets.zero,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.photo_album_outlined,
                              size: 30,
                              color: Colors.blue,
                            ),
                            title: Text(
                              "Update Profile Picture",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop(); // Close the dialog
                              final pickedImage = await handleImageSelection();
                              if (_pickedImage != null) {
                                setState(() {
                                  _pickedImage = _pickedImage;
                                });
                                await _cropImage();
                              }
                            },
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                            color: Colors.white,
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.delete,
                              size: 30,
                              color: Colors.red,
                            ),
                            title: Text(
                              "Delete Profile Picture",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop(); // Close the dialog
                              removeProfilePicture(); // Remove the profile picture
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                // If no image is picked, directly open image selection
                final pickedImage = await handleImageSelection();
                if (_pickedImage != null) {
                  setState(() {
                    _pickedImage = _pickedImage;
                  });
                  await _cropImage();
                }
              }
            },
            leading: Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        // Add more ListTile items for your existing options
        
        // Contact ExpansionTile
        ExpansionTile(
          leading: Icon(
            Icons.contact_phone,
            color: Colors.white,
          ),
          title: Text(
            'Contact',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            ListTile(
              onTap: () {
                // Open Instagram page
                // Replace 'your_instagram_url' with your actual Instagram URL
                launch('https://www.instagram.com/');
              },
              leading: Icon(
                Icons.add_box,
                color: Colors.white,
              ),
              title: Text(
                'Instagram',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                // Open Twitter page
                // Replace 'your_twitter_url' with your actual Twitter URL
                launch('https://twitter.com/home');
              },
              leading: Icon(
                Icons.link,
                color: Colors.white,
              ),
              title: Text(
                'Twitter',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                // Open phone dialer with your phone number
                // Replace 'your_phone_number' with your actual phone number
                launch('tel:+123456789');
              },
              leading: Icon(
                Icons.phone,
                color: Colors.white,
              ),
              title: Text(
                'Phone',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        // Your existing ListTile items
        
        ListTile(
          onTap: _signOut,
          leading: Icon(
            Icons.logout,
            color: Colors.white,
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ),
),

  







   body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20), //Size box top
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
             
             


              child: Container(
  height: 120,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 253, 253, 253).withOpacity(0.3),
        spreadRadius: 2,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.blue,
                Color.fromARGB(255, 4, 2, 1),
      ],
    ),
  ),
  padding: EdgeInsets.all(16),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [





   GestureDetector(
  onTap: () async {
    if (_pickedImage != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: null,
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_album_outlined, size: 30),
                  title: Text(
                    "Update Profile Picture",
                    style: TextStyle(fontSize: 17), // Adjust the font size here
                  ),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    // Call handleImageSelection to select a new image
                    final pickedImage = await handleImageSelection();
                    if (_pickedImage != null) {
                      // Set the picked image to the variable
                      setState(() {
                        _pickedImage = _pickedImage;
                      });

                      // Call cropImage method with the picked image
                      _cropImage();
                    }
                  },
                ),
                Divider(height: 0, thickness: 1, color: Colors.grey),
                ListTile(
                  leading: Icon(Icons.delete, size: 30, color: Colors.red),
                  title: Text(
                    "Delete Profile Picture",
                    style: TextStyle(fontSize: 17), // Adjust the font size here
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // User confirmed removal, so remove the profile picture
                    removeProfilePicture();
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Call handleImageSelection to select an image
      final pickedImage = await handleImageSelection();
      if (_pickedImage != null) {
        // Set the picked image to the variable
        setState(() {
          _pickedImage = _pickedImage;
        });

        // Call cropImage method with the picked image
        _cropImage();
      }
    }
  },
  child: Stack(
    alignment: Alignment.center,
    children: [
      CircleAvatar(
        radius: 48,
        backgroundColor: Colors.white,
        child: _pickedImage != null
            ? ClipOval(
                child: Image.file(
                  _pickedImage!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              )
            : Icon(
                Icons.person,
                size: 48,
                color: Colors.blue,
              ),
      ),
    ],
  ),
),




      SizedBox(width: 20),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hello,",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${_user?.displayName ?? 'Guest'}!",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  ),
),




            ),
          ),


          const SizedBox(height: 10),








           // Add your image below the profile container with curved edges
Center(
  child: Container(
    width: 368, // Adjust the width as needed for the image container
    child: Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 500, // Adjust the width as needed for the image container
                  height: 160,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        imagePaths[index],
                        width: 500, // Adjust the width as needed for the image container
                        height: 150,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 13), // image and weather kelg hopuk
            Center(


              child: Container(
  width: 380, // Adjust the width as needed for the weather container
  child: Card(
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    color: Colors.blue, // You can change the color to represent the weather condition
    child: Padding(
      padding: const EdgeInsets.all(12), // Reduce padding for a smaller size
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 24, // Reduce the icon size
                  ),
                  Text(
                    'Hum',
                    style: TextStyle(
                      fontSize: 14, // Reduce the font size
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$humidity',
                    style: TextStyle(
                      fontSize: 18, // Reduce the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  (() {
                    int parsedDay;
                    try {
                      parsedDay = int.parse(day);
                    } catch (e) {
                      parsedDay = -1; // Set a default value or handle the error as needed
                    }

                    switch (parsedDay) {
                      case 0:
                        return Icon(
                          Icons.brightness_3_rounded,
                          color: Colors.white,
                          size: 35,
                        );
                      case 1:
                        return Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
                          size: 24,
                        );
                      default:
                        return Icon(
                          Icons.help_outline,
                          color: Colors.white,
                          size: 24,
                        );
                    }
                  })(),
                  Text(
                    '',
                    style: TextStyle(
                      fontSize: 5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    (() {
                      int parsedDay;
                      try {
                        parsedDay = int.parse(day);
                      } catch (e) {
                        parsedDay = -1; // Set a default value or handle the error as needed
                      }

                      switch (parsedDay) {
                        case 0:
                          return 'Night';
                        case 1:
                          return 'Day';
                        default:
                          return 'Unknown';
                      }
                    })(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.gas_meter_outlined,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 24, // Reduce the icon size
                  ),
                  Text(
                    'Pressure',
                    style: TextStyle(
                      fontSize: 14, // Reduce the font size
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$last',
                    style: TextStyle(
                      fontSize: 18, // Reduce the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8), // Reduce spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Colors.white,
                    size: 24, // Reduce the icon size
                  ),
                  Text(
                    'Temp',
                    style: TextStyle(
                      fontSize: 14, // Reduce the font size
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$temperature',
                    style: TextStyle(
                      fontSize: 18, // Reduce the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.cloud,
                    color: Colors.white,
                    size: 24, // Reduce the icon size
                  ),
                  Text(
                    'Condition',
                    style: TextStyle(
                      fontSize: 14, // Reduce the font size
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$condition',
                    style: TextStyle(
                      fontSize: 18, // Reduce the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.speed,
                    color: Colors.white,
                    size: 24, // Reduce the icon size
                  ),
                  Text(
                    'Wind',
                    style: TextStyle(
                      fontSize: 14, // Reduce the font size
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$windSpeed',
                    style: TextStyle(
                      fontSize: 18, // Reduce the font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),






              
            ),



          ],
        ),
      ),
    ),
  ),
),

















  


    const SizedBox(height:0),
   
 

    


    Expanded(
  child: Container(
  
  padding: const EdgeInsets.all(1),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust this as needed
    children: [
      _buildFeatureCard(
        "Select Field",
        Icons.location_on,
        [Colors.blue, Color.fromARGB(255, 4, 2, 1)],
        "area",
      ),
      _buildSavedDataCard(
        "Saved Data",
        Icons.save,
        [Colors.blue, const Color.fromARGB(255, 1, 4, 4)],
      ),
    ],
  ),
),


    ),



const SizedBox(height:10), //SS
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildNpkButton(),
    _buildTmButton(),
  ],
),
const SizedBox(height:20), //SS
  
  Container(
  alignment: Alignment.center,
  padding: const EdgeInsets.only(bottom: 10),
  child: ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, 'quick');
    },
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.zero, // Remove default padding
    ),
    child: Container(
      width: 367,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue,
                const Color.fromARGB(255, 1, 4, 4),], // button colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
        children: [
          Icon(
            Icons.nature,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            'Quick Data Access',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
  ),
),

SizedBox(height: 9,)

  ],
),

  );
}

Widget _buildNpkButton() {
  return Container(
    height: 60,
    width: 165,
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'npk');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 4, 2, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.graphic_eq, // Replace with the desired icon
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 5),
              Text(
                'NPK',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTmButton() {
  return Container(
    height: 60,
    width: 165,
    child: InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'tm');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 4, 2, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop_rounded, // Replace with the desired icon
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 0),
              Text(
                'Temp/Hum',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      "login",
      (route) => false,
    );
  }

Widget _buildFeatureCard(
  String title, IconData iconData, List<Color> gradientColors, String? routeName,
) {
  return Container(
    height: 60,
    width: 165, // Set the height to 20
    child: InkWell(
      onTap: () {
        if (routeName == "saved") {
          _showSavedDataPopup();
        } else if (routeName != null) {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 2), // Add some spacing between icon and text
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
}



Widget _buildSavedDataCard(
  String title, IconData iconData, List<Color> gradientColors,
) {
  return Container(
    height: 60,
    width: 165, // Set the height to 20
    child: InkWell(
      onTap: () {
        _showSavedDataPopup();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 5), // Add some spacing between icon and text
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
}






  void _showSavedDataPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 250, 253, 255), Color.fromARGB(255, 255, 253, 253)], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPopupButton(
                "Crop Prediction",
                Icons.search,
                [Colors.blue, Color.fromARGB(255, 0, 0, 0)], // Gradient colors
                "save",
              ),
              const SizedBox(height: 15),
              _buildPopupButton(
                "Fertilizer Recommendation",
                Icons.star,
                [Colors.blue, Color.fromARGB(255, 0, 0, 0)], // Gradient colors
                "save1",
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
}

Widget _buildPopupButton(
  String title,
  IconData iconData,
  List<Color> gradientColors, // Use List<Color> for gradient colors
  String? routeName,
) {
  return ElevatedButton.icon(
    onPressed: () {
      if (routeName != null) {
        Navigator.pushNamed(context, routeName);
      }
    },
    icon: Icon(
      iconData,
      color: Colors.white,
    ),
    label: Text(
      title,
      style: TextStyle(
        fontFamily: 'Montserrat',
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      primary: null, // Remove the primary color
      onPrimary: Colors.white, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      // Add gradient background
     
    ),
  );
}

}







