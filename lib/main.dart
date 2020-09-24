import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [
    "Dowglas", "Kayron"
  ];

  Future<File> _getFile() async {
    final pathDirectory = await getApplicationDocumentsDirectory();
    return File("${pathDirectory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList); // covert a lista um para json
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(75, 0, 130, 1);
// ref cores: https://celke.com.br/artigo/tabela-de-cores-html-nome-hexadecimal-rgb#:~:text=No%20HTML%2C%20as%20cores%20podem%20ser%20nomeadas%20pelo,codificadas%2C%20por%20n%C3%BAmeros%20hexadecimais%2C%20como%2C%20FFAA00%20%E2%80%93%201%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C9%2Ca%2Cb%2Cc%2Cd%2Ce%2Cf.
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: color,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        labelText: "Nova Tarefa",
                        labelStyle: TextStyle(color: color)),
                  ),
                ),
                RaisedButton(
                  color: color,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: () {},
                )
              ],
            ),
          ),

          //Lista
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                itemCount: _toDoList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_toDoList[index]),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
