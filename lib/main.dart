import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pair_base/helpers.dart';
import 'package:pair_base/widgets/empty_data_set.dart';
import 'package:pair_base/widgets/new_item_fab.dart';

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

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
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

  void createList(String key) async {
    var result = addNewList(selectedKey!, key);
    setState(() {
      currentSet = result;
    });
  }

  void addListValue(String newValue) async {
    var result = addValueToList(selectedKey!, newValue);
    setState(() {
      currentSet = result;
    });
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
                  : Center(child: Builder(builder: (context) {
                      return ListView.builder(
                        itemCount: currentSet.length,
                        itemBuilder: (context, index) {
                          var currentKey = currentSet is List
                              ? currentSet[index]
                              : currentSet.keys.elementAt(index);
                          var currentValue = currentSet is List
                              ? currentSet[index]
                              : currentSet.values.elementAt(index);
                          return Dismissible(
                            key: Key(currentKey),
                            onDismissed: (direction) {},
                            background: Container(
                              color: Colors.red,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: currentSet is! List
                                    ? Text(currentKey.toString()[0])
                                    : currentSet.isEmpty
                                        ? Text(currentSet.toString())
                                        : Text(currentSet[index].toString()[0]),
                              ),
                              title: currentSet is! List
                                  ? Text(currentKey.toString())
                                  : currentSet.isEmpty
                                      ? Text(currentSet.toString())
                                      : Text(currentSet[index].toString()),
                              subtitle: currentSet is List
                                  ? null
                                  : Text(currentSet.values
                                      .elementAt(index)
                                      .toString()),
                              trailing: Visibility(
                                visible:
                                    currentSet is! List && currentValue is List,
                                child: const Icon(Icons.arrow_forward_ios),
                              ),
                              onTap: () async {
                                await evaluateItemSelection(index, context);
                              },
                            ),
                          );
                        },
                      );
                    })),
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
                                "Are you sure you want to delete everything?"),
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
              floatingActionButton: NewItemFab(
                  selectedKey: selectedKey,
                  formKey: _formKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController),
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
}
