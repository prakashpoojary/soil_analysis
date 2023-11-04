import 'package:flutter/material.dart';

class MyStart extends StatelessWidget {
  const MyStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
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
            Icon(
              Icons.recommend,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Recomendations",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedButton(
              text: "Crop Prediction",
              icon: Icons.grass,
              onPressed: () {
                Navigator.pushNamed(context, "soil",
                    arguments: "Crop Recommendation");
              },
            ),
            SizedBox(height: 20),
            AnimatedButton(
              text: "Fertilizer Recomendation",
              icon: Icons.filter_vintage,
              onPressed: () {
                Navigator.pushNamed(context, "soil1",
                    arguments: "Fertilizer Recommendation");
              },
            ),
          ],
        ),
      ),
    );
  }
}


class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function() onPressed;

  AnimatedButton({required this.text, required this.icon, required this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _scale = 1.1;
        });
      },
      onExit: (_) {
        setState(() {
          _scale = 1.0;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 300 * _scale,
        height: 80 * _scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _scale == 1.0
                ? [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),]
                : [Colors.blue,
                Color.fromARGB(255, 4, 2, 1),],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
    home: MyStart(),
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Montserrat',
    ),
  ));
}
