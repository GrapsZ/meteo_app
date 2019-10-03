import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_meteo/widgets/StyledText.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageCities {

  Function addCityState;

  ManageCities(this.addCityState);

  Future<Null> addCity(context) async {
    return showDialog(
      barrierDismissible: true,
        builder: (BuildContext buildContext) {
        return new SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: new StyledText().textWithStyle("Ajouter une ville", fontSize: 22.0, color: Colors.blue),
          children: <Widget>[
            new TextField(
              decoration: new InputDecoration(labelText: "ville: "),
              onSubmitted: (String str) {
                this.addCityState(str);
                Navigator.pop(buildContext);
              },
            )
          ],
        );
      },
      context: context);
  }
}