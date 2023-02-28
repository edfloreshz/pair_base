import 'package:flutter/material.dart';

class EmptyDataSet extends StatelessWidget {
  const EmptyDataSet({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
          "Quite empty in here, try adding some values using the + button"),
    ));
  }
}
