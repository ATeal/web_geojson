import 'package:flutter/material.dart';
import 'package:geojson/geojson.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geojson Web Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Geojson Web Test'),
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
  final _featureCollection = GeoJsonFeatureCollection();

  @override
  void initState() {
    super.initState();
    fetchGeoJson();
  }

  void fetchGeoJson() async {
    final data = await rootBundle
        .loadString('assets/geojson/us_congressional_districts.json');

    featuresFromGeoJsonMainThread(data);
  }

  Future<GeoJsonFeatureCollection> featuresFromGeoJsonMainThread(String data,
      {String nameProperty, bool verbose = false}) async {
    final geojson = GeoJson();
    try {
      await geojson.parseInMainThread(data,
          nameProperty: nameProperty, verbose: verbose);
    } catch (e) {
      rethrow;
    }
    geojson.features.forEach((f) {
      if (verbose) {
        print("Feature: ${f.type}");
      }
      setState(() {
        _featureCollection.collection.add(f);
      });
    });
    geojson.dispose();
    return _featureCollection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have this many geojson features:',
            ),
            Text(
              '${_featureCollection.collection.length}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
