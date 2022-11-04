import 'dart:convert';

import 'package:apiconflutter/models/Gif.dart';
import 'package:apiconflutter/models/morty.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'RICK AND MORTY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Morty>> _listadodeMorty;

  Future<List<Morty>> _getListMorty() async {
    final response = await http.get(Uri.parse(
        "https://rickandmortyapi.com/api/character/?page=19"));

    List<Morty> mortys = [];

    if (response.statusCode == 200) {
      //me aseguro que lo de codifico en UTF8, sólo para asegurar que todo este en castellano
      String body = utf8.decode(response.bodyBytes);
      //convertimos el body en un objeto Json
      final jsonData = jsonDecode(body);
      // print(jsonData["data"][0]["type"]);

      for (var item in jsonData["results"]) {
        mortys.add(Morty(item["name"], item["species"],item["image"],item["type"]));
      }

      return mortys;
    } else {
      throw Exception("Falló la conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listadodeMorty = _getListMorty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: _listadodeMorty,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              //return Text("data");

              // --return ListView(
              return GridView.count(
                  crossAxisCount: 2, // sólo con gridview
                  //permite eliminar restricciones en lista
                  // https://www.fluttercampus.com/guide/228/renderbox-was-not-laid-out-error/
                  shrinkWrap: true,
                  children: _listadeMorty(snapshot.data));
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("error");
            }
            // retorno por defecto - circulito que carga algo
            return Center(child: CircularProgressIndicator());
          },

        ));
  }

  List<Widget> _listadeMorty(data) {
    List<Widget> mortys = [];
    for (var morty in data) {
      mortys.add(Card(
          child: Column(
            children: [
              Expanded(child: Image.network(morty.image, fit: BoxFit.fill)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(morty.name),
              ),
            ],
          )));
    }
    return mortys;
  }
}
