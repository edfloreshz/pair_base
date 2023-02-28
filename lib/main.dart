import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pair_base/enums/data_type.dart';
import 'package:pair_base/validations.dart';
import 'package:pair_base/widgets/empty_data_set.dart';

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
  String title = "Pair Base";
  String? selectedKey;
  dynamic currentSet = {};
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _keyController;
  late TextEditingController _valueController;

  @override
  void initState() {
    _keyController = TextEditingController();
    _valueController = TextEditingController();
    super.initState();
  }

  Future<Map<String, dynamic>> getRootData() async {
    var root = jsonDecode(await storage.read(key: "root") ?? "{}");
    setState(() {
      if (selectedKey != null && currentSet is List) {
        currentSet = root[selectedKey];
      } else {
        currentSet = root;
      }
    });
    return root;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRootData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var root = snapshot.data!;
          return Scaffold(
              appBar: AppBar(
                leading: Visibility(
                  visible: selectedKey != null,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: updateSet,
                  ),
                ),
                centerTitle: true,
                title: Text(title),
              ),
              body: root.isEmpty
                  ? const EmptyDataSet()
                  : Center(
                      child: ListView.builder(
                      itemCount: currentSet.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: currentSet is! List
                                ? Text(currentSet.keys
                                    .elementAt(index)
                                    .toString()[0])
                                : currentSet.isEmpty
                                    ? Text(currentSet.toString())
                                    : Text(currentSet[index].toString()[0]),
                          ),
                          title: currentSet is! List
                              ? Text(
                                  currentSet.keys.elementAt(index).toString())
                              : currentSet.isEmpty
                                  ? Text(currentSet.toString())
                                  : Text(currentSet[index].toString()),
                          subtitle: currentSet is List
                              ? null
                              : Text(currentSet.values
                                  .elementAt(index)
                                  .toString()),
                          trailing: Visibility(
                            visible: currentSet is! List &&
                                currentSet.values.elementAt(index) is List,
                            child: const Icon(Icons.arrow_forward_ios),
                          ),
                          onTap: () async {
                            await evaluateItemSelection(index, context);
                          },
                        );
                      },
                    )),
              bottomNavigationBar: BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: updateSet,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete"),
                            content: const Text(
                                "Are you sure you want to delete this?"),
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
                children: selectedKey != null
                    ? [
                        FloatingActionButton.small(
                          onPressed: () async =>
                              await addData(context, DataType.string),
                          tooltip: 'Text',
                          child: const Icon(Icons.text_fields),
                        ),
                        FloatingActionButton.small(
                          onPressed: () async =>
                              await addData(context, DataType.number),
                          tooltip: 'Number',
                          child: const Icon(Icons.numbers),
                        ),
                      ]
                    : [
                        FloatingActionButton.small(
                          onPressed: () async =>
                              await addData(context, DataType.string),
                          tooltip: 'Text',
                          child: const Icon(Icons.text_fields),
                        ),
                        FloatingActionButton.small(
                          onPressed: () async =>
                              await addData(context, DataType.number),
                          tooltip: 'Number',
                          child: const Icon(Icons.numbers),
                        ),
                        FloatingActionButton.small(
                          onPressed: () async =>
                              await addData(context, DataType.list),
                          tooltip: 'List',
                          child: const Icon(Icons.data_array),
                        )
                      ],
              ),
              floatingActionButtonLocation: ExpandableFab.location);
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void updateSet() async {
    var root = jsonDecode(await storage.read(key: "root") ?? "{}");
    setState(() {
      currentSet = root;
      selectedKey = null;
      title = "Pair Base";
    });
  }

  Future<void> evaluateItemSelection(int index, BuildContext context) async {
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentSet is List) {
      await Clipboard.setData(
          ClipboardData(text: currentSet.elementAt(index).toString()));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard"),
          duration: Duration(milliseconds: 500),
        ),
      );
    } else if (currentSet.values.elementAt(index) is List) {
      setState(() {
        selectedKey = currentSet.keys.elementAt(index);
        if (selectedKey != null) {
          title = selectedKey!;
        }
        currentSet = currentSet.values.elementAt(index);
      });
    } else {
      await Clipboard.setData(
          ClipboardData(text: currentSet.values.elementAt(index).toString()));
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard"),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  addData(BuildContext context, DataType dataType) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: dataType == DataType.string
            ? const Text("Add Text")
            : dataType == DataType.number
                ? const Text("Add Number")
                : const Text("Add List"),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              Visibility(
                visible: currentSet is! List,
                child: TextFormField(
                  controller: _keyController,
                  validator: (key) => validateKey(key, currentSet),
                  decoration: const InputDecoration(
                    hintText: "Key",
                  ),
                ),
              ),
              Visibility(
                visible: dataType != DataType.list,
                child: TextFormField(
                  controller: _valueController,
                  validator:
                      dataType == DataType.string || dataType == DataType.list
                          ? validateEmpty
                          : validateNumber,
                  decoration: const InputDecoration(
                    hintText: "Value",
                  ),
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
              if (_formKey.currentState!.validate()) {
                if (dataType == DataType.list) {
                  addNewList(_keyController.text);
                } else if (dataType == DataType.number) {
                  if (selectedKey != null) {
                    addValueToList(_valueController.text);
                  } else {
                    addNewRow(_keyController.text, _valueController.text);
                  }
                } else if (dataType == DataType.string) {
                  if (selectedKey != null) {
                    addValueToList(_valueController.text);
                  } else {
                    addNewRow(_keyController.text, _valueController.text);
                  }
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void addNewRow(String key, dynamic value) async {
    var root = await storage.read(key: "root");
    Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
    rootMap.addEntries([MapEntry(key, value)]);
    storage.write(key: "root", value: jsonEncode(rootMap));
  }

  void addNewList(String key) async {
    var root = await storage.read(key: "root");
    Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
    rootMap.addEntries([MapEntry(key, [])]);
    setState(() {
      currentSet = rootMap[selectedKey];
    });
    storage.write(key: "root", value: jsonEncode(rootMap));
  }

  void addValueToList(String newValue) async {
    var root = await storage.read(key: "root");
    Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
    rootMap.update(selectedKey!, (value) => [...value, newValue]);
    setState(() {
      currentSet = rootMap[selectedKey];
    });
    storage.write(key: "root", value: jsonEncode(rootMap));
  }
}
