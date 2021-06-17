/*
  This is the widget that will appear on the homescreen to show user's stat.
 */

import 'package:flutter/material.dart';

class UserStat extends StatelessWidget {
  final double avgScore;
  final int bestScore;
  final int gamesPlayed;

  UserStat({this.avgScore, this.bestScore, this.gamesPlayed});

  Widget get _userStatwidget {
    return Stack(
      children: [
        Container(
          transform: Matrix4.translationValues(95, -10, 0),
          child: _userInfoCard(
            size: 125,
            title: 'Best Score',
            value: bestScore.toString(),
            color: Color.fromRGBO(35, 96, 50, 1.0),
            boarderColor: Color.fromRGBO(74, 159, 4, 1.0),
            fontColor: Colors.white,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(40, 100, 0),
          child: _userInfoCard(
            size: 100,
            title: 'Games Played',
            value: gamesPlayed.toString(),
            color: Colors.yellow[600],
            boarderColor: Colors.yellow[300],
            fontColor: Colors.black,
          ),
        ),
        Container(
          transform: Matrix4.translationValues(-65, -30, 0),
          child: _userInfoCard(
            size: 150,
            title: 'Average Score',
            value: avgScore.toStringAsFixed(1),
            color: Colors.blue,
            boarderColor: Colors.blue[100],
            fontColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _userInfoCard({
    double size,
    String title,
    String value,
    Color color,
    Color boarderColor,
    Color fontColor,
  }) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 5),
        border: Border.all(
          width: 2,
          color: boarderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: fontColor,
              fontSize: size * (2 / 17),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: fontColor,
              fontSize: size * (4 / 15),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _userStatwidget;
  }
}
