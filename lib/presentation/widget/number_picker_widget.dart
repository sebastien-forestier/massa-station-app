// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:numberpicker/numberpicker.dart';

class NumberPickerWidget extends StatefulWidget {
  const NumberPickerWidget({super.key});

  @override
  _NumberPickerWidgetState createState() => _NumberPickerWidgetState();
}

class _NumberPickerWidgetState extends State<NumberPickerWidget> {
  double _currentDoubleValue = 0.01;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 5),
        Text('Fee: ${_currentDoubleValue.toString()}'),
        const SizedBox(width: 5),
        DecimalNumberPicker(
          value: _currentDoubleValue,
          minValue: 0,
          maxValue: 10,
          decimalPlaces: 2,
          itemHeight: 40,
          itemWidth: 20,
          onChanged: (value) => setState(() {
            _currentDoubleValue = value;
            debugPrint(_currentDoubleValue.toString());
          }),
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
