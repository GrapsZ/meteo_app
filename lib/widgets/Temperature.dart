class Temperature {
  String main;
  String description;
  String icon;
  String country;

  var pressure;
  var humidity;
  var temp;
  var min;
  var max;

  //"main":{"temp":303.2,"pressure":1008,"humidity":58,"temp_min":299.26,"temp_max":307.15},"visibility":16093,"wind":{"speed":2.6,"deg":50},"rain":{"1h":0.25},"clouds":{"all":40},"dt":1570051021,"sys":{"type":1,"id":5141,"message":0.0112,"country":"US","sunrise":1570013590,"sunset":1570055852},"timezone":-14400,"id":5128581,"name":"New York","cod":200}

  Temperature(Map map) {
    List weather = map["weather"];
    Map weatherMap = weather.first;
    this.main = weatherMap["main"];
    this.description = weatherMap["description"];
    this.icon = weatherMap["icon"];
    Map mainMap = map["main"];
    this.temp = mainMap["temp"];
    this.pressure = mainMap["pressure"];
    this.humidity = mainMap["humidity"];
    this.min = mainMap["temp_min"];
    this.max = mainMap["temp_max"];
    Map sysMap = map["sys"];
    this.country = sysMap["country"];
  }

}