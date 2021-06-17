import 'package:flutter/material.dart';
import 'package:golf_scorecard/ui/screens/new_game_screen.dart';
import 'package:golf_scorecard/ui/screens/score_history_screen.dart';
import 'package:golf_scorecard/ui/screens/settings_screen.dart';
import 'package:golf_scorecard/ui/widget/custom_button.dart';
import 'package:golf_scorecard/ui/widget/user_stat.dart';
import 'package:golf_scorecard/data/data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State Variables
  double _avgScore = 0;
  int _bestScore = 0;
  int _gamesPlayed = 0;

  // update database and set new state
  _update() {
    setState(() {
      _loadStat();
    });
  }

  // load player stat from database and calculate avg
  Future<void> _loadStat() async {
    List<Map> allGames = await DB.instance.getAllGames();

    int best = 0;
    int playerTotalPar = 0;
    for (Map game in allGames) {
      List<String> gamePars = game[DB.columnPar].toString().split(',');
      Map temp = (await DB.instance.getPlayerID(game[DB.columnGameID]))[0];
      List<String> playerScore = temp[DB.columnScore].toString().split(',');

      int gameScore = 0;
      for (int i = 0; i < playerScore.length; i++) {
        if (int.parse(playerScore[i]) > 0) {
          gameScore += int.parse(playerScore[i]) - int.parse(gamePars[i]);
        }
      }
      playerTotalPar += gameScore;
      best = gameScore < best ? gameScore : best;
    }

    _avgScore = playerTotalPar / allGames.length;
    _bestScore = best;
    _gamesPlayed = allGames.length;
  }

  _onPressedStartNewGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewGameScreen(
          title: 'Start New Game',
          func: _update,
        ),
      ),
    ).then((value) {
      setState(() {
        _loadStat();
      });
    });
  }

  _onPressedScoreHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreHistoryScreen(
          title: 'Score History',
        ),
      ),
    ).then((value) {
      setState(() {
        _loadStat();
      });
    });
  }

  // Widgets
  Widget get _titleSection {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              child: Icon(Icons.settings, size: 30, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(title: 'Settings'),
                  ),
                );
              },
            ),
          ),
        ]),
        Text(
          'ScoreCard',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontFamily: 'KaushanScript',
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget get _buttonsSection {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            btnLabel: 'Start New Game',
            onPressed: _onPressedStartNewGame,
          ),
          CustomButton(
            btnLabel: 'Score History',
            color: Colors.grey[850],
            onPressed: _onPressedScoreHistory,
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    UserPreference.initPref().then((value) {
      _loadStat().then((value) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _titleSection,
            UserStat(
              gamesPlayed: _gamesPlayed,
              avgScore: _avgScore,
              bestScore: _bestScore,
            ),
            _buttonsSection,
          ],
        ),
      ),
    );
  }
}
