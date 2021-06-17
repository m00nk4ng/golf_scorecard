/*
  This custom designed widget will be used everytime there needs to be a 
  information section. It was made into seperate file in case multiple screen 
  would required this, but currently it is only used in the score history 
  screen.
 */

import 'package:flutter/material.dart';

class CustomPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  CustomPanel({this.child, this.padding = const EdgeInsets.all(13.0)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0, 1),
            blurRadius: 1.0,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
