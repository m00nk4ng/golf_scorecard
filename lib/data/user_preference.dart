import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  static final int _prefVersion = 2;
  static final String _version = 'version',
      showCircle = 'showCircle',
      showSquare = 'showSquare',
      showAsStroke = 'showAsStroke',
      player1Name = 'player1Name',
      player2Name = 'player2Name',
      player3Name = 'player3Name',
      player4Name = 'player4Name';

  static SharedPreferences sp;

  static Future<void> initPref() async {
    sp = await SharedPreferences.getInstance();
    if (sp.getInt(_version) == null || sp.getInt(_version) < _prefVersion) {
      sp.setInt(_version, _prefVersion);
      sp.setBool(showCircle, false);
      sp.setBool(showSquare, false);
      sp.setBool(showAsStroke, false);
      sp.setString(player1Name, 'Me');
      sp.setString(player2Name, 'Golfer 2');
      sp.setString(player3Name, 'Golfer 3');
      sp.setString(player4Name, 'Golfer 4');
    }
  }
}
