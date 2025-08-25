import 'package:flutter/material.dart';

//color
Color mainColor = Color.fromRGBO(255, 204, 0, 1);
//const String BASE_URL = 'http://10.0.2.2:8000';
const String BASE_URL = 'http://152.42.170.154:8001';
String userId = '5dc917096e1c39409c4534c7';
String token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1ZGM5MTcwOTZlMWMzOTQwOWM0NTM0YzciLCJpYXQiOjE1NzM2NTE5MDZ9.L80pvEEkwdTeon3UImY8gSq59E0vqFinVBY8-XhN6hE';

//Style
const headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,);
const headerStyle2 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black,);
const titleStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const priceTitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const titleStyle2 = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
const subtitleStyle = TextStyle(fontSize: 14, color: Colors.black54);
const infoStyle = TextStyle(fontSize: 12, color: Colors.black54);
const footerStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);

const headerReceipt = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
const headerMobileReceipt = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
const subHeaderReceipt = TextStyle(fontSize: 22);
const itemReceipt = TextStyle(fontSize: 20,  );
const itemTotalReceipt = TextStyle(fontSize: 28, fontWeight: FontWeight.bold  );
const itemTotalMobileReceipt = TextStyle(fontSize: 22, fontWeight: FontWeight.bold  );

const headerIconSize = 32.0;
const menuCardRadius = 8.0;

final menuRoundedRectangle = RoundedRectangleBorder(
  borderRadius: BorderRadiusDirectional.circular(menuCardRadius),
);

//Decoration
final roundedRectangle12 = RoundedRectangleBorder(
  borderRadius: BorderRadiusDirectional.circular(12),
);

final roundedRectangle4 = RoundedRectangleBorder(
  borderRadius: BorderRadiusDirectional.circular(4),
);

const roundedRectangle40 = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
);