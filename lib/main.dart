import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:my_meteo/widgets/ManageCities.dart';
import 'package:my_meteo/widgets/StyledText.dart';
import 'package:my_meteo/widgets/Temperature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:my_meteo/widgets/my_flutter_app_icons.dart';

void main() {
  // Application uniquement disponible en portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'GrapsZ Météo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String key = "cities";
  List<String> cities = [];
  String chosenCity;
  Coordinates coordsChosenCity;
  Temperature temperature;
  Location location;
  LocationData locationData;
  Stream<LocationData> stream;
  String nameCurrent = "Ville actuelle";

  AssetImage night = AssetImage("assets/n.jpg");
  AssetImage sun = AssetImage("assets/d1.jpg");
  AssetImage rain = AssetImage("assets/d2.jpg");

  @override
  void initState() {
    super.initState();
    obtain();
    location = new Location();
    //getFirstLocation();
    listenStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      drawer: new Drawer(
        child: new Container(
          child: new ListView.builder(
              itemCount: cities.length + 2,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return DrawerHeader(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new StyledText()
                            .textWithStyle("Mes villes", fontSize: 22.0),
                        new RaisedButton(
                            color: Colors.white,
                            elevation: 8.0,
                            child: new StyledText().textWithStyle(
                                "Ajouter une ville",
                                color: Colors.blue),
                            onPressed: () {
                              new ManageCities(this.add).addCity(context);
                            })
                      ],
                    ),
                  );
                } else if (i == 1) {
                  return new ListTile(
                    title: new StyledText().textWithStyle(nameCurrent),
                    onTap: () {
                      setState(() {
                        chosenCity = null;
                        coordsChosenCity = null;
                        api();
                        Navigator.pop(context);
                      });
                    },
                  );
                } else {
                  String city = cities[i - 2];
                  return new ListTile(
                    title: new StyledText().textWithStyle(city),
                    trailing: new IconButton(
                        icon: new Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: (() => delete(city))),
                    onTap: () {
                      setState(() {
                        chosenCity = city;
                        coordsFromCity();
                        // ferme le drawer
                        Navigator.pop(context);
                      });
                    },
                  );
                }
              }),
          color: Colors.blue,
        ),
      ),
      body: (temperature == null) 
          ? Center( child: new Text((chosenCity == null) ? nameCurrent : chosenCity))
          : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: new BoxDecoration(
          image: new DecorationImage(image: getBackground(), fit: BoxFit.cover) // fit Boxfit force l'image à prendre l'intégralité du cadre.
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // espacer de façon égale les éléments de ma colonne
          children: <Widget>[
            new StyledText().textWithStyle((chosenCity) == null ? nameCurrent : chosenCity, fontSize: 40.0, fontStyle: FontStyle.italic),
            new StyledText().textWithStyle(temperature.description, fontSize: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                //new Image.network("http://openweathermap.org/img/wn/${temperature.icon}@2x.png"),
                new Image(image: getIcon()),
                new StyledText().textWithStyle("${temperature.temp.toInt()} °C", fontSize: 30.0)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                extra("${temperature.min.toInt()} °C", MyFlutterApp.down),
                extra("${temperature.max.toInt()} °C", MyFlutterApp.up),
                extra("${temperature.pressure.toInt()}", MyFlutterApp.temperatire),
                extra("${temperature.humidity.toInt()} %", MyFlutterApp.drizzle),
              ],
            )
          ],
        ),
      ),
    );
  }

  Column extra(String data, IconData iconData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(iconData, color: Colors.white, size: 32.0),
        new StyledText().textWithStyle(data),
      ],
    );
  }

  // Shared Preferences
  void obtain() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> list = await sharedPreferences.getStringList(key);
    if (list != null) {
      setState(() {
        cities = list;
      });
    }
  }

  void add(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.add(str);
    await sharedPreferences.setStringList(key, cities);
    obtain();
  }

  void delete(String str) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.remove(str);
    await sharedPreferences.setStringList(key, cities);
    obtain();
  }

  AssetImage getIcon() {
    String icon = temperature.icon.replaceAll('d', '').replaceAll('n', '');
    return AssetImage("assets/$icon.png");
  }

  AssetImage getBackground() {
    // On regarde si l'api retourne un icone contenant un n ( nuit )
    if (temperature.icon.contains("n")) {
      return night;
    } else {
      if ((temperature.icon.contains("01")) || (temperature.icon.contains("02")) || (temperature.icon.contains("03"))) {
        return sun;
      } else {
        return rain;
      }
    }
  }

  // Une seule fois
  getFirstLocation() async {
    try {
      locationData = await location.getLocation();
      //print("Nouvelle position: ${locationData.latitude} / ${locationData.longitude}");
      locationToString();
    } catch (e) {
      print("nous avons un erreur : $e");
    }
  }

  // Chaque chargement / changement
  listenStream() {
    stream = location.onLocationChanged();
    stream.listen((newPosition) {
      if ((locationData == null) || (newPosition.longitude != locationData.longitude) && (newPosition.latitude != locationData.latitude)) {
        setState(() {
          locationData = newPosition;
          locationToString();
        });
      }
    });
  }

  locationToString() async {
    if (locationData != null) {
      Coordinates coordinates = new Coordinates(locationData.latitude, locationData.longitude);
      final cityName = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      setState(() {
        nameCurrent = cityName.first.locality;
        api();
      });
    }
  }

  coordsFromCity() async {
    if (chosenCity != null) {
      List<Address> addresses = await Geocoder.local.findAddressesFromQuery(chosenCity);
      if (addresses.length > 0) {
        Address first = addresses.first;
        Coordinates coords = first.coordinates;
        setState(() {
          coordsChosenCity = coords;
          api();
        });
      }
    }
  }

  api() async {
    double lat;
    double lon;
    if (coordsChosenCity != null) {
      lat = coordsChosenCity.latitude;
      lon = coordsChosenCity.longitude;
    } else if (locationData != null) {
      lat = locationData.latitude;
      lon = locationData.longitude;
    }

    if (lat != null && lon != null) {
      final key = "&APPID=5cc5003492f5910c52b6b360bc07ec65";
      String lang = "&lang=${Localizations.localeOf(context).languageCode}";
      String baseAPI = "http://api.openweathermap.org/data/2.5/weather?";
      String coordsString = "lat=$lat&lon=$lon";
      String units = "&units=metric";
      String totalString = baseAPI + coordsString + units + lang + key;

      // Appel API
      final response = await http.get(totalString);
      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        setState(() {
          temperature = Temperature(map);
          //print(temperature.description);
        });
      }
    }
  }
}
