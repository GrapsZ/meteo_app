
import 'package:flutter/material.dart';

class StyledText {

  StyledText();

  Text textWithStyle(String data, {color: Colors.white, fontSize: 18.0, fontStyle: FontStyle.italic, textAlign: TextAlign.center}){
    return new Text(
      data,
      textAlign: textAlign,
      style: new TextStyle(
        color: color,
        fontSize: fontSize,
        fontStyle: fontStyle,
      ),
    );
  }
}