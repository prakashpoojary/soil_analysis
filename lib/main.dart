import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:SoilAnalysis/area.dart';
import 'package:SoilAnalysis/home.dart';
import 'package:SoilAnalysis/start.dart';
import 'package:SoilAnalysis/plots.dart';
import 'package:SoilAnalysis/soil.dart';
import 'package:SoilAnalysis/soil1.dart';
import 'package:SoilAnalysis/quick.dart';
import 'package:SoilAnalysis/npk.dart';
import 'package:SoilAnalysis/tm.dart';
import 'package:SoilAnalysis/ph.dart';
import 'package:SoilAnalysis/ec.dart';
import 'package:SoilAnalysis/moisture.dart';

import 'package:SoilAnalysis/notification.dart';
import 'package:SoilAnalysis/choose.dart';
import 'package:SoilAnalysis/soil0.dart';
import 'package:SoilAnalysis/splash.dart';
import 'auth/forgetpass.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'savedvalues0.dart';
import 'savedValues.dart';
import 'savedValues1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "splash",
    routes: {

      "start": (context) => MyStart(),
      "home": (context) => MyHome(),
      "area": (context) => MyArea(),
      "plot": (context) => MyPlots(),
      "soil0": (context) => MySoilData0(),
      "soil": (context) => MySoilData(),
      "soil1": (context) => MySoilData1(),
      "quick": (context) => MySoilData2(),
      "notification": (context) => NotificationScreen(),
      "choose": (context) => ChoosePage(),
      "npk": (context) => MySoilData3(),
      "tm": (context) => MySoilData4(),
      "ph": (context) => MySoilData5(),
      "ec": (context) => MySoilData6(),
      "moisture": (context) => MySoilData7(),


      
     
      
      "save0": (context) => AreaList0(),
      "save": (context) => AreaList(),
      "save1": (context) => AreaList1(),
      'login': (context) => MyLogin(),
      'signup': (context) => MySignUp(),
      'forgotpass': (context) => ForgotPasswordPage(),
      'splash': (context) => MySplash()
    },
  ));
}
