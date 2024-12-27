import 'package:flutter/material.dart';
import 'package:mug/constants/colors.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final Color labelBackgroundColour;
  final String value;
  final Color valueBackgroundColour;
  final double radius;

  CustomChip(
      {required this.label,
      required this.value,
      required this.labelBackgroundColour,
      required this.valueBackgroundColour,
      this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Color(blueSoul)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                color: labelBackgroundColour,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  bottomLeft: Radius.circular(radius),
                )),
            //color: Colors.black,
            child: Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                color: valueBackgroundColour,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                )),
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
