import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class NotificationScreen extends StatelessWidget {
  final List<dynamic>? articles; // Make the parameter nullable

  NotificationScreen({this.articles}); // Allow the parameter to be nullable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),], // Your gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: articles != null && articles!.isNotEmpty // Check if articles are available
          ? ListView.builder(
              itemCount: articles!.length,
              itemBuilder: (context, index) {
                final article = articles![index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      article['title'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        article['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                   onTap: () async {
  if (article['url'] != null) {
    if (await canLaunch(article['url'])) {
      await launch(article['url'], forceWebView: true);

    } else {
      print('Could not launch ${article['url']}');
    }
  } else {
    print('URL is null');
  }
},


                  ),
                );
              },
            )
          : Center(
              child: Text('No articles available.'),
            ), // Display a message if no articles are available
    );
  }
}




