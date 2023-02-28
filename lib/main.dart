import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const PairBase());
}

class PairBase extends StatelessWidget {
  const PairBase({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pair Base',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.amber),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String previousKey = "";
  String selectedKey = "";
  Map<String, dynamic> root = {
    // "Seguro Social": "123456789",
    // "Amigos": [
    //   "Juan",
    //   "Pedro",
    //   "Maria",
    // ],
    // "Datos de mi empresa": {
    //   "Nombre de empresa": "TCS",
    //   "Mas info": {
    //     "Telefono": "22211221",
    //   }
    // }
  };
  dynamic currentSet = {};
  String title = "Pair Base";
  final storage = const FlutterSecureStorage();

  late TextEditingController _keyController;
  late TextEditingController _valueController;

  @override
  void initState() {
    _keyController = TextEditingController();
    _valueController = TextEditingController();
    super.initState();
  }

  Future<Map<String, dynamic>> getRootData() async {
    return jsonDecode(await storage.read(key: "root") ?? jsonEncode({}));
  }

  void setDummyData() {
    storage.write(key: "root", value: jsonEncode(root));
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentSet.isEmpty) {
      reloadData();
    }
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
          centerTitle: true,
          title: Text(title),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: currentSet.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: currentSet is List
                      ? Text(currentSet[index].toString()[0])
                      : Text(currentSet.keys.elementAt(index).toString()[0]),
                ),
                title: currentSet is List
                    ? Text(currentSet[index].toString())
                    : Text(currentSet.keys.elementAt(index).toString()),
                subtitle: currentSet is List
                    ? null
                    : currentSet.values.elementAt(index) is Map
                        ? const Text("Click to see more")
                        : Text(currentSet.values.elementAt(index).toString()),
                trailing: Visibility(
                  visible: currentSet is Map &&
                      (currentSet.values.elementAt(index) is Map ||
                          currentSet.values.elementAt(index) is List),
                  child: const Icon(Icons.arrow_forward_ios),
                ),
                onTap: () async {
                  if (currentSet is List) {
                    await Clipboard.setData(
                        ClipboardData(text: currentSet[index].toString()));
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text("Copied to clipboard"),
                        duration: Duration(milliseconds: 500),
                      ),
                    );
                  } else {
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
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text("Copied to clipboard"),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  setState(() {
                    selectedKey = "";
                    title = 'Pair Base';
                    currentSet = root;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete"),
                      content:
                          const Text("Are you sure you want to delete this?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            storage.deleteAll();
                            setState(() {
                              currentSet = {};
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: ExpandableFab(
          child: const Icon(Icons.add),
          children: [
            FloatingActionButton.small(
              onPressed: () async => await addTextEntry(context),
              tooltip: 'Text',
              child: const Icon(Icons.text_fields),
            ),
            FloatingActionButton.small(
              onPressed: () => addNumberEntry(),
              tooltip: 'Number',
              child: const Icon(Icons.numbers),
            ),
            FloatingActionButton.small(
              onPressed: () => addListEntry(),
              tooltip: 'List',
              child: const Icon(Icons.data_array),
            ),
            FloatingActionButton.small(
              onPressed: () => addObjectEntry(),
              tooltip: 'Object',
              child: const Icon(Icons.data_object),
            )
          ],
        ),
        floatingActionButtonLocation: ExpandableFab.location);
  }

  void reloadData() async {
    var data = await getRootData();
    setState(() {
      root = data;
      currentSet = root;
    });
  }

  addTextEntry(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Entry"),
        content: Center(
          child: Column(
            children: [
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
              ),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(
                  hintText: "Value",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addEntry(_keyController.text, _valueController.text);
              Navigator.of(context).pop();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  addNumberEntry() {}

  addListEntry() {}

  addObjectEntry() {}

  void addEntry(String key, dynamic value) async {
    if (selectedKey != "") {
      if (root.containsKey(key)) {
        root[selectedKey][key] = value;
      } else {
        root[selectedKey].addEntries([MapEntry(key, value)]);
      }
    } else {
      if (root.containsKey(key)) {
        root[key] = value;
      } else {
        root.addEntries([MapEntry(key, value)]);
      }
    }
    storage.write(key: "root", value: jsonEncode(root));
    reloadData();
  }
}
