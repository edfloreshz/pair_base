import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pair Base',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String previousKey = "";
  String selectedKey = "";
  Map<dynamic, dynamic> root = {
    "Seguro Social": "123456789",
    "Bancomer CVV": "1234",
    "DHL Camiseta Hacktoberfest": "123456789",
    "Amigos": [
      "Juan",
      "Pedro",
      "Maria",
    ],
    "Datos de mi trabajo": {
      "Nombre de empresa": "TCS",
      "Telefono": "123456789",
      "Direccion": "Calle 123",
      "Mas info": {
        "Nombre": "Maria",
        "Apellido": "Gonzalez",
        "Edad": "45",
        "Telefono": "123456789",
        "Direccion": "Calle 123",
      }
    }
  };
  dynamic currentSet = {};
  String title = "Pair Base";

  @override
  void initState() {
    super.initState();
    currentSet = root;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Visibility(
          visible: selectedKey != "",
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              setState(() {
                if (previousKey != "") {
                  selectedKey = previousKey;
                  title = selectedKey;
                  currentSet = root[previousKey];
                } else {
                  selectedKey = "";
                  title = 'Pair Base';
                  currentSet = root;
                }
                if (root[previousKey] != null) {
                  previousKey = "";
                }
              });
            },
          ),
        ),
        title: Text(title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: currentSet.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                child: currentSet is List
                    ? Text(currentSet[index].toString()[0])
                    : Text(currentSet.keys.elementAt(index).toString()[0]),
              ),
              title: currentSet is List
                  ? Text(currentSet[index].toString())
                  : Text(currentSet.keys.elementAt(index).toString()),
              subtitle: currentSet is List
                  ? null
                  : Text(
                      currentSet.values.elementAt(index).toString().length > 20
                          ? "Click to see more"
                          : currentSet.values.elementAt(index).toString()),
              trailing: Visibility(
                visible: currentSet is Map &&
                    (currentSet.values.elementAt(index) is Map ||
                        currentSet.values.elementAt(index) is List),
                child: const Icon(Icons.arrow_forward_ios),
              ),
              onTap: () async {
                if (currentSet.values.elementAt(index) is Map) {
                  setState(() {
                    if (selectedKey != "") {
                      previousKey = selectedKey;
                    }
                    selectedKey = currentSet.keys.elementAt(index);
                    title = selectedKey;
                    currentSet = currentSet.values.elementAt(index);
                  });
                } else if (currentSet.values.elementAt(index) is List) {
                  setState(() {
                    if (selectedKey != "") {
                      previousKey = selectedKey;
                    }
                    selectedKey = currentSet.keys.elementAt(index);
                    title = selectedKey;
                    currentSet = currentSet.values.elementAt(index);
                  });
                } else {
                  await Clipboard.setData(ClipboardData(
                      text: currentSet.values.elementAt(index).toString()));
                }
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
