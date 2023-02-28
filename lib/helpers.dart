import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pair_base/validations.dart';

import 'enums/data_type.dart';

void addNewRow(String key, dynamic value) async {
  const storage = FlutterSecureStorage();
  var root = await storage.read(key: "root");
  Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
  rootMap.addEntries([MapEntry(key, value)]);
  storage.write(key: "root", value: jsonEncode(rootMap));
}

dynamic addNewList(String? selectedKey, String key) async {
  const storage = FlutterSecureStorage();
  var root = await storage.read(key: "root");
  Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
  rootMap.addEntries([MapEntry(key, [])]);

  storage.write(key: "root", value: jsonEncode(rootMap));
  return rootMap[selectedKey];
}

dynamic addValueToList(String selectedKey, String newValue) async {
  const storage = FlutterSecureStorage();
  var root = await storage.read(key: "root");
  Map<String, dynamic> rootMap = jsonDecode(root ?? "{}");
  rootMap.update(selectedKey, (value) => [...value, newValue]);

  storage.write(key: "root", value: jsonEncode(rootMap));
  return rootMap[selectedKey];
}

addData(
  BuildContext context,
  DataType dataType,
  GlobalKey<FormState> formKey,
  String? selectedKey,
  dynamic currentSet,
  TextEditingController keyController,
  TextEditingController valueController,
) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: dataType == DataType.string
          ? const Text("Add Text")
          : dataType == DataType.number
              ? const Text("Add Number")
              : const Text("Add List"),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            Visibility(
              visible: currentSet is! List,
              child: TextFormField(
                controller: keyController,
                validator: (key) => validateKey(key, currentSet),
                decoration: const InputDecoration(
                  hintText: "Key",
                ),
              ),
            ),
            Visibility(
              visible: dataType != DataType.list,
              child: TextFormField(
                controller: valueController,
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
            if (formKey.currentState!.validate()) {
              if (dataType == DataType.list) {
                addNewList(null, keyController.text);
              } else if (dataType == DataType.number) {
                if (selectedKey != null) {
                  addValueToList(selectedKey, valueController.text);
                } else {
                  addNewRow(keyController.text, valueController.text);
                }
              } else if (dataType == DataType.string) {
                if (selectedKey != null) {
                  addValueToList(selectedKey, valueController.text);
                } else {
                  addNewRow(keyController.text, valueController.text);
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
