/*
  This Custom designed button will be used everytime there needs to be a button
  on the screen. The Button needs to have a label in it.
 */

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function onPressed;
  final String btnLabel;
  final Color color;

  CustomButton({
    @required this.btnLabel,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(btnLabel),
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          padding: EdgeInsets.all(13.0),
          primary: color,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
