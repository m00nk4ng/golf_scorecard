/*
 * This class will define the object that the data will parse to when read from
 * database.
 */

import 'db.dart';

// The game object will hold information about the course. Such as course name,
// par, and the date
class Game {
  final int iD;
  String courseName;
  String date;
  String par;

  Game({this.iD, this.courseName, this.date, this.par});

  // Parse Map to a Game object
  static Game fromMap(Map<String, dynamic> map) {
    return new Game(
      iD: map[DB.columnGameID],
      courseName: map[DB.columnCourseName],
      date: map[DB.columnDate],
      par: map[DB.columnPar],
    );
  }

  // Parse Game object to a Map that can be written to db
  Map<String, dynamic> toMap() => {
        DB.columnGameID: iD,
        DB.columnCourseName: courseName,
        DB.columnDate: date,
        DB.columnPar: par,
      };

  // Return the par of the given hole
  int getPar(int index) {
    List<String> temp = par.split(',');
    return int.parse(temp[index]);
  }

  // Update the par of the give hole. It also checks if the
  // given new value is valid.
  updatePar(int newPar, int holeIndex) {
    List<String> temp = par.split(',');
    int newValue = (int.parse(temp[holeIndex]) + newPar);
    if (newValue < 2)
      temp[holeIndex] = '1';
    else if (newValue > 9)
      temp[holeIndex] = '9';
    else
      temp[holeIndex] = newValue.toString();
    String updated = '';
    for (String i in temp) {
      updated += (i + ',');
    }
    updated = updated.substring(0, updated.length - 1);

    par = updated;
  }

  // Reset the par of the given hole to its default; 4
  resetPar(int holeIndex) {
    List<String> temp = par.split(',');
    temp[holeIndex] = '4';
    String updated = '';
    for (String i in temp) {
      updated += (i + ',');
    }
    updated = updated.substring(0, updated.length - 1);

    par = updated;
  }
}

// The player object will hold information about the player. Such as which
// course they were playing on, their name, and their score.
class Player {
  final int iD;
  final int fK;
  String playerName;
  String score;

  Player({this.iD, this.fK, this.playerName, this.score});

  // Parse Map to a Player object
  static Player fromMap(Map<String, dynamic> map) {
    return new Player(
      iD: map[DB.columnPlayerID],
      fK: map[DB.columnGameFK],
      playerName: map[DB.columnPlayer],
      score: map[DB.columnScore],
    );
  }

  // Parse Player object to a Map that can be written to db
  Map<String, dynamic> toMap() => {
        DB.columnPlayerID: iD,
        DB.columnGameFK: fK,
        DB.columnPlayer: playerName,
        DB.columnScore: score,
      };

  // Return player's score of the given hole
  int getScore(int index) {
    List<String> temp = score.split(',');
    return int.parse(temp[index]);
  }

  // Update the score of the given hole.
  setScore(int newScore, int holeIndex) {
    List<String> temp = score.split(',');
    temp[holeIndex] = newScore.toString();
    String updated = '';
    for (String i in temp) {
      updated += (i + ',');
    }
    updated = updated.substring(0, updated.length - 1);
    score = updated;
  }

  // Increment the score of the given hole
  incrementScore(int value, int holeIndex) {
    List<String> temp = score.split(',');
    int newValue = (int.parse(temp[holeIndex]) + value);
    temp[holeIndex] = (newValue < 1) ? '0' : newValue.toString();
    String updated = '';
    for (String i in temp) {
      updated += (i + ',');
    }
    updated = updated.substring(0, updated.length - 1);
    score = updated;
  }

  // Reset the score of given hole to 0 stroke
  resetScore(int holeIndex) {
    List<String> temp = score.split(',');
    temp[holeIndex] = '0';
    String updated = '';
    for (String i in temp) {
      updated += (i + ',');
    }
    updated = updated.substring(0, updated.length - 1);
    score = updated;
  }
}
