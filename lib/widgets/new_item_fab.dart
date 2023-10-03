import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:pair_base/widgets/buttons/new_list.dart';
import 'package:pair_base/widgets/buttons/new_number.dart';
import 'package:pair_base/widgets/buttons/new_text.dart';

class NewItemFab extends StatelessWidget {
  const NewItemFab({
    Key? key,
    required this.selectedKey,
    required GlobalKey<FormState> formKey,
    required this.currentSet,
    required TextEditingController keyController,
    required TextEditingController valueController,
  })  : _formKey = formKey,
        _keyController = keyController,
        _valueController = valueController,
        super(key: key);

  final String? selectedKey;
  final GlobalKey<FormState> _formKey;
  final dynamic currentSet;
  final TextEditingController _keyController;
  final TextEditingController _valueController;

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.add),
        fabSize: ExpandableFabSize.regular,
        shape: const CircleBorder(),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.small,
        shape: const CircleBorder(),
      ),
      children: selectedKey != null
          ? [
              NewTextButton(
                  formKey: _formKey,
                  selectedKey: selectedKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController),
              NewNumberRowButton(
                  formKey: _formKey,
                  selectedKey: selectedKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController),
            ]
          : [
              NewTextButton(
                  formKey: _formKey,
                  selectedKey: selectedKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController),
              NewNumberRowButton(
                  formKey: _formKey,
                  selectedKey: selectedKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController),
              NewListButton(
                  formKey: _formKey,
                  selectedKey: selectedKey,
                  currentSet: currentSet,
                  keyController: _keyController,
                  valueController: _valueController)
            ],
    );
  }
}
