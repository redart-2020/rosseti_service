import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rosseti_service/data/location.dart';
import 'package:rosseti_service/data/session_options.dart';
import 'package:rosseti_service/data/static_variable.dart';
import 'package:http/http.dart' as http;
import 'package:rosseti_service/data/users_devices.dart';
import '../module_common.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<DropdownMenuItem<Location>> house_options = [];
  List<Location> house_date;
  Location house;

  List<Location> locations_data;
  List<UsersDevices> users_devices_data;
  List<UsersDevices> users_devices_location_data = [];

  TabController tab_controller;
  TabPageSelector tab_page_selector;

  List<Widget> tab_list = [];

  final List<Color> _colors = [
    Colors.green,
    Colors.yellow,
    Colors.red,
  ];
  double _colorSliderPosition = 0;

  @override
  void initState() {
    super.initState();
    tab_list.add(Tab(
        child: Text(
      'Все устройства',
      style: TextStyle(color: Colors.black45),
    )));
    tab_controller = TabController(length: tab_list.length, vsync: this);

    refreshList();
  }

  downloadHouseOptions() async {
    final jsonEndpoint = '${ServerUrl}/locations/?top=true';
    try {
      final response = await http.get(jsonEndpoint,
          headers: {'Authorization': 'Basic ${AuthorizationString}'});
      if (response.statusCode == 200) {
        List locations = json.decode(response.body);
        house_date = await locations
            .map((locations) => new Location.fromJson(locations))
            .toList();
        for (var house_item in house_date) {
          house_options.add(new DropdownMenuItem<Location>(
            value: house_item,
            child: new Text(house_item.name),
          ));
        };

      } else
        print(response.body);
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CreateDefaultMasterForm(0, getBody(), context, null);
  }

  getHomeRoomsData() async {
    final jsonEndpoint = '${ServerUrl}/locations/?parent=${house.id}';
    try {
      final response = await http.get(jsonEndpoint,
          headers: {'Authorization': 'Basic ${AuthorizationString}'});
      if (response.statusCode == 200) {
        List locations = json.decode(response.body);
        return locations
            .map((locations) => new Location.fromJson(locations))
            .toList();

      } else
        print(response.body);
    } catch (error) {
      print(error.toString());
    }
  }

  getUsersDevicesData() async {
    final jsonEndpoint = '${ServerUrl}/user_devices/?location=${house.id}';
    try {
      final response = await http.get(jsonEndpoint,
          headers: {'Authorization': 'Basic ${AuthorizationString}'});
      if (response.statusCode == 200) {
        List users_devices = json.decode(response.body);
        return users_devices
            .map((users_devices) => new UsersDevices.fromJson(users_devices))
            .toList();

      } else
        print(response.body);
    } catch (error) {
      print(error.toString());
    }
  }

  getBody() {
    return Column(
      children: [
        new Expanded(
          flex: 1,
          //margin: EdgeInsets.fromLTRB(0, 0, 10.0, 0),
          child: ListTile(
            title: new DropdownButton<Location>(
                isExpanded: true,
                underline: new Divider(),
                hint: new Text("Выберите дом",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left),

                //underline: Text('Топливная карта'),
                value: house,
                items: house_options,
                onChanged: (newVal) async {
                  house = newVal;
                  locations_data = await getHomeRoomsData();
                  users_devices_data = await getUsersDevicesData();

                  setState(() {
                    tab_list.clear();
                    tab_list.add(Tab(
                        child: Text(
                      'Все устройства',
                      style: TextStyle(color: Colors.black45),
                    )));
                    for (var locations_item in locations_data) {
                      tab_list.add(
                        Tab(
                            child: Text(locations_item.name,
                                style: TextStyle(color: Colors.black45))),
                      );
                    }
                    tab_controller =
                        TabController(length: tab_list.length, vsync: this);
                    users_devices_location_data.clear();
                    users_devices_location_data.addAll(users_devices_data);

                    _colorSliderPosition = house.current_consumption * (MediaQuery.of(context).size.width * 0.8/house.max_consumption);
                  });
                }),
            trailing: Icon(Icons.add_circle),
          ),
        ),
        house==null?new Expanded(
          flex: 9,
          child: Column(
            children: [
              Container(
                margin: new EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Дом не указан',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              new Container(
                margin: EdgeInsets.all(30.0),
                child: new Image.asset(
                  "assets/images/grust.png",
                  height: MediaQuery.of(context).size.height*0.5,
                ),
              )
            ],
          ),
        ):Container(),
        house!=null?new Expanded(
          flex: 3,
          child: Column(children: [
            Container(
              margin: new EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Текущая нагрузка',
                style: TextStyle(fontSize: 20),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.grey[800]),
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(colors: _colors),
                  ),
                  child: CustomPaint(
                    painter: _SliderIndicatorPainter(_colorSliderPosition),
                  ),
                ),
              ),
            ),
            Container(
                margin: new EdgeInsets.only(bottom: 5.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text('0 кВТ'),
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        '${house.max_consumption*1.33} кВТ',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                )),
            Container(
              margin: new EdgeInsets.only(bottom: 5.0),
              child: Text(
                'Нагрузка: ${house.current_consumption.toStringAsFixed(2)} кВТ/ч',
                style: TextStyle(fontSize: 15),
              ),
            ),
            Container(
              //margin: new EdgeInsets.only(bottom: 5.0),
              child: Text(
                'Расход: ${(house.tariff*house.current_consumption).toStringAsFixed(2)} р/ч',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ]),
        ):Container(),
        house!=null?new Expanded(
          flex: 1,
          child: TabBar(
            key: Key(Random().nextDouble().toString()),
            controller: tab_controller,
            tabs: tab_list,
            onTap: (int index){
              setState(() {
                users_devices_location_data.clear();
                for(var users_devices_item in users_devices_data){
                  if(index == 0 || users_devices_item.location_id == locations_data[index-1].id){
                    users_devices_location_data.add(users_devices_item);
                  }
                }
              });
            },
          ),
        ):Container(),
        house!=null?new Expanded(
            flex: 5,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2,
              children: List.generate(users_devices_location_data.length, (index) {
                return Center(
                  child: Card(
                    child: ListTile(
                      title: Text(users_devices_location_data[index].name),
                      subtitle: Text(users_devices_location_data[index].location_name!=null?users_devices_location_data[index].location_name:'Не распределен'),
                      trailing: Icon(Icons.power_settings_new),
                    ),
                  ),
                );
              }),
            )):Container()
      ],
    );
  }

  Future<Null> refreshList() async {
    await this.downloadHouseOptions();
    setState(() {
//      this.isLoading = false;
    });

    return null;
  }
}

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  _SliderIndicatorPainter(this.position);
  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawCircle(
        Offset(position, size.height / 2), 10, Paint()..color = Colors.black);
  }
  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return true;
  }
}
