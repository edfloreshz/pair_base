import 'package:flutter/material.dart';
import 'package:pair_base/enums/data_type.dart';
import 'package:pair_base/helpers.dart';

class NewListButton extends StatelessWidget {
  const NewListButton({
    Key? key,
    required GlobalKey<FormState> formKey,
    required this.selectedKey,
    required this.currentSet,
    required TextEditingController keyController,
    required TextEditingController valueController,
  })  : _formKey = formKey,
        _keyController = keyController,
        _valueController = valueController,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final String? selectedKey;
  final dynamic currentSet;
  final TextEditingController _keyController;
  final TextEditingController _valueController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () async => await addData(context, DataType.list, _formKey,
          selectedKey, currentSet, _keyController, _valueController),
      tooltip: 'List',
      child: const Icon(Icons.data_array),
    );
  }
}
