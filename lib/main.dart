import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // para não esperar a resposta
import 'dart:convert'; // para converter para json

const request =
    "https://api.hgbrasil.com/finance?format=json-cors?key=9db4d633";

void main() async {
  print(await getData());
  runApp(MaterialApp(
    title: "conversor de moedas",
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: Text("\$ Conversor \$"),
        ),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Carregando",
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ));

                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao Carregar Dados",
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ));
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(Icons.monetization_on,
                                size: 150, color: Colors.amber),
                            buildTextField(
                                "Reais", "R\$ ", realController, _realChanged),
                            Divider(),
                            buildTextField("Dolares", "USD ", dolarController,
                                _dolarChanged),
                            Divider(),
                            buildTextField(
                                "Euros", "€ ", euroController, _euroChanged)
                          ],
                        ));
                  }
              }
            }));
    //cafoold serve para permitir o uso da appbar no top
  }
}

Future<Map> getData() async {
  //future é para criar um mapa do futuro
  http.Response response = await http
      .get(request); // usa-se o await para esperar a resposta do futuro
  return jsonDecode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function funcao) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: TextStyle(color: Colors.amber),
    decoration: InputDecoration(
        prefixText: prefix,
        border: OutlineInputBorder(),
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber, fontSize: 25)),
    onChanged: funcao,
  );
}
