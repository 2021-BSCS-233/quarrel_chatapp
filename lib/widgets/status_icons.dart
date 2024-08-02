import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatusIcon extends StatelessWidget {
  final String iconType;
  final double? iconSize;
  final double? iconBorder;
  final Color? borderColor;

  const StatusIcon(
      {super.key,
      required this.iconType,
      this.iconBorder,
      this.iconSize,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    double size = iconSize ?? 16.0;
    double border = iconBorder ?? 2.5;
    if (iconType == 'Online') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(width: border, color: borderColor ?? Colors.black),
          shape: BoxShape.circle,
          color: Colors.green,
        ),
      );
    } else if (iconType == 'DND') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(width: border, color: borderColor ?? Colors.black),
          shape: BoxShape.circle,
          color: Colors.red.shade600,
        ),
        child: Center(
          child: Container(
            height: size / 6,
            width: size / 2.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              color: Colors.black,
            ),
          ),
        ),
      );
    } else if (iconType == 'Asleep') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(width: border, color: borderColor ?? Colors.black),
          shape: BoxShape.circle,
          color: borderColor ?? Colors.black,
        ),
        child: Icon(
          CupertinoIcons.moon_fill,
          color: Colors.yellow,
          size: size / 1.4,
        ),
      );
    } else if (iconType == 'Offline') {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(width: border),
          shape: BoxShape.circle,
          color: Colors.grey.shade600,
        ),
        child: Center(
          child: Container(
            width: size / 3.5,
            height: size / 3.5,
            decoration: BoxDecoration(
                border:
                    Border.all(width: 0, color: borderColor ?? Colors.black),
                color: Colors.black,
                shape: BoxShape.circle),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(width: border),
          shape: BoxShape.circle,
          color: Colors.grey.shade600,
        ),
        child: Center(
          child: Container(
            width: size / 3.5,
            height: size / 3.5,
            decoration: BoxDecoration(
                border: Border.all(width: 0),
                color: Colors.black,
                shape: BoxShape.circle),
          ),
        ),
      );
    }
  }
}
