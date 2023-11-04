import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AreaList0 extends StatefulWidget {
  @override
  _AreaList0State createState() => _AreaList0State();


}


class _AreaList0State extends State<AreaList0> {
  final dbRef = FirebaseDatabase.instance.reference();
  final searchController = StreamController<String>();

  @override
  void dispose() {
    searchController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(236, 149, 46, 228), 
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white), // Icon before the title
            SizedBox(width: 8),
            Text(
              'Areas',
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
              stream: dbRef.child('saved_data/${FirebaseAuth.instance.currentUser?.displayName}').onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic>? values = snapshot.data?.snapshot.value as Map?;
                  if (values != null && values.isNotEmpty) {
                    List<String> keys = values.keys.cast<String>().toList();
                    keys.sort();

                    return StreamBuilder<String>(
                      stream: searchController.stream,
                      builder: (context, searchSnapshot) {
                        final searchQuery = searchSnapshot.data?.toLowerCase() ?? '';

                        final filteredKeys = keys.where((key) => key.toLowerCase().contains(searchQuery)).toList();

                        return ListView.builder(
                          itemCount: filteredKeys.length,
                          itemBuilder: (context, index) {
                            String key = filteredKeys[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlotList(areaId: key.toString()),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "$key",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Montserrat', // Replace with your custom font
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

class PlotList extends StatelessWidget {
  final dbRef = FirebaseDatabase.instance.reference();
  final String areaId;

  PlotList({required this.areaId});

  final searchController = StreamController<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(236, 149, 46, 228),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white), // Icon before the title
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
                      'saved_data/${FirebaseAuth.instance.currentUser?.displayName}/$areaId')
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
                                          Color(0xFFFFA726),
                                          Color(0xFFFF7043)
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


class DataList extends StatelessWidget {
  final dbRef = FirebaseDatabase.instance.reference();
  final String areaId;
  final String plotId;

  DataList({required this.areaId, required this.plotId});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(236, 149, 46, 228),
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.data_usage), // Add your desired icon here
            SizedBox(width: 8), // Add spacing between icon and title
            Text(
              'Saved Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: dbRef
            .child('saved_data/${FirebaseAuth.instance.currentUser?.displayName}/$areaId/$plotId')
            .onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            Map<dynamic, dynamic>? values = snapshot.data?.snapshot.value as Map?;
            if (values != null && values.isNotEmpty) {
              return ListView.builder(
                itemCount: values.length,
                itemBuilder: (context, index) {
                  var entry = values.entries.elementAt(index);

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.blue[50], // Adjust the background color
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timestamp:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            timeToDate(entry.key.toString()),
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Data Value:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${entry.value.toString()}',
                            style: TextStyle(fontSize: 14),
                          ),
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
    );
  }
}