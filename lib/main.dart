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
  final _toDoController = TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;

  void _addToDo() {
    setState(() {
      if (_toDoController.text.isEmpty) {
        return;
      }
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;

      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    /*obtem a responta apois 1 segundo*/
    await Future.delayed(Duration(seconds: 1));

    /*Atualizando a Lista com ordem de tarefas ja concluidas OK*/
    setState(() {
      _toDoList.sort((a, b) {
        if (a['ok'] && !b['ok'])
          return 1;
        else if (!a['ok'] && b['ok'])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
    return null;
  }

  /*Sobrecarga do metodo inital*/
  @override
  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

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
                    controller: _toDoController,
                  ),
                ),
                RaisedButton(
                  color: color,
                  child: Text("ADD"),
                  textColor: Colors.white,
                  onPressed: _addToDo,
                )
              ],
            ),
          ),

          //Lista
          Expanded(
              child: RefreshIndicator(
                  child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      itemCount: _toDoList.length,
                      itemBuilder: buildItem),
                  onRefresh: _refresh)),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      //gerando uma key com a data e hora atual.
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0), // -1.0 a 1.0
          child: Icon(
            Icons.delete_outline,
            color: Colors.white60,
          ),
        ),
      ),

      //direção
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          //Atualiza o estado da operação
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        // 'setState' (atualiza a lista apos a ação realizada, neste caso o delete de um dos intens da lista)
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snackbar = SnackBar(
            content:
                Text("Tafera \"${_lastRemoved['title']}\" removida da Lista!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _toDoList.insert(_lastRemovedPos,
                        _lastRemoved); // insere a tafera na lista novamente
                    _saveData();
                  });
                }),
            duration: Duration(seconds: 3),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snackbar);
        });
      },
    );
  }
}
