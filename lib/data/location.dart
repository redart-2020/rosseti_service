class Location {
  String name, description;
  int parent, id;
  double current_consumption, max_consumption, tariff;
  Location({this.name, this.description, this.parent, this.current_consumption, this.max_consumption, this.id, this.tariff});

  factory Location.fromJson(Map<String, dynamic> jsonData) {

    return Location(
        name: jsonData['name'],
        description: jsonData['description'],
        parent: jsonData['parent'],
        max_consumption: jsonData['max_consumption']!=null?jsonData['max_consumption']:0.0,
        current_consumption: jsonData['current_consumption']!=null?jsonData['current_consumption']:0.0,
        id: jsonData['id'],
        tariff: jsonData['tariff']
    );
  }

}