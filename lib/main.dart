import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    'https://api.hgbrasil.com/finance?format=json-cors&key=ba136413';

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _realChangerd(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar!).toStringAsFixed(2);
    euroController.text = (real / euro!).toStringAsFixed(2);
  }

  void _dolarChangerd(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void _euroChangerd(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          " \$ Conversor \$",
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados :( ",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]['USD']['buy'];
                euro = snapshot.data!['results']["currencies"]['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                        "Reais",
                        "R\$",
                        realController,
                        _realChangerd,
                      ),
                      Divider(),
                      buildTextField(
                        "Dólares",
                        "\$",
                        dolarController,
                        _dolarChangerd,
                      ),
                      Divider(),
                      buildTextField(
                        "Euros",
                        "\€",
                        euroController,
                        _euroChangerd,
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function(String) function) {
  return TextField(
    controller: controller,
    onChanged: function,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
  );
}
