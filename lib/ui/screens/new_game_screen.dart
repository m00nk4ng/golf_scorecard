import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golf_scorecard/ui/widget/custom_button.dart';
import 'package:golf_scorecard/ui/screens/scorecard_screen.dart';
import 'package:golf_scorecard/data/data.dart';
import 'package:golf_scorecard/ui/constant.dart';

class NewGameScreen extends StatefulWidget {
  final String title;

  final Function func;

  NewGameScreen({@required this.title, this.func});

  @override
  _NewGameScreenState createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  // State Variables
  PageController _pageController;
  String _courseName;
  DateTime _date;
  List<String> _players = [];

  // Widgets
  Widget _appBar(context) => AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.grey[850],
            fontWeight: FontWeight.w300,
          ),
        ),
        elevation: 0.7,
        leading: BackButton(
          color: Colors.grey[850],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  List<Widget> get _playerNameList {
    List<Widget> toBeReturned = [];
    for (int i = 0; i < _players.length; i++)
      toBeReturned.add(
        TextFormField(
          onChanged: (value) {
            setState(() {
              _players[i] = value;
            });
          },
          initialValue: _players[i],
          style: TextStyle(
            fontSize: 19,
            color: Colors.blueGrey[900],
          ),
          decoration: InputDecoration(
            hintText: 'Golfer ${i + 1}',
            hintStyle: TextStyle(
              fontSize: 19,
              color: Colors.grey[300],
            ),
          ),
          maxLines: 1,
        ),
      );
    return toBeReturned;
  }

  Widget _courseNameAndDateForm(context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enter Course Name', style: kTitleStyle),
            TextFormField(
              initialValue: _courseName,
              onChanged: (value) {
                setState(() {
                  _courseName = value;
                });
              },
              style: kTextFieldStyle,
              decoration: InputDecoration(
                hintText: 'Untitled Golf Course',
                hintStyle: kHintStyle,
              ),
              maxLines: 1,
              autofocus: true,
            ),
            SizedBox(height: 30),
            Text(
              'Enter Date',
              style: TextStyle(
                fontSize: 27,
                color: Colors.blueGrey[850],
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 50,
              child: CupertinoDatePicker(
                onDateTimeChanged: (value) => _date = value,
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
              ),
            ),
            SizedBox(height: 30),
            CustomButton(
              btnLabel: 'Next',
              color: Colors.green,
              onPressed: () {
                FocusScope.of(context).unfocus();
                _pageController.animateToPage(
                  _pageController.page.toInt() + 1,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              },
            ),
          ],
        ),
      );

  Widget _playerNamesForm(context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Player Names',
                style: TextStyle(
                  fontSize: 27,
                  color: Colors.blueGrey[850],
                ),
              ),
              Column(
                children: _playerNameList,
              ),
              SizedBox(height: 15),
              CustomButton(
                btnLabel: 'Start Game!',
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  _pageController.dispose();

                  await DB.instance.insertGame(
                    Game(
                      courseName: _courseName == ''
                          ? 'Untitiled Golf Course'
                          : _courseName,
                      date: _date.toString(),
                      par: '4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4',
                    ),
                  );
                  List temp = await DB.instance.getAllGames();
                  int id = temp.last[DB.columnGameID];
                  for (var i = 0; i < _players.length; i++) {
                    await DB.instance.insertPlayer(
                      new Player(
                        fK: id,
                        playerName:
                            _players[i] == '' ? 'Golfer ${i + 1}' : _players[i],
                        score: '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0',
                      ),
                    );
                  }

                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScorecardScreen(
                        id: id,
                        courseName: _courseName == ''
                            ? 'Untitiled Golf Course'
                            : _courseName,
                      ),
                    ),
                  ).then((value) {
                    widget.func();
                  });
                },
              ),
              CustomButton(
                btnLabel: 'Back',
                color: Colors.grey,
                onPressed: () {
                  _pageController.animateToPage(
                    _pageController.page.toInt() - 1,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                  );
                },
              ),
            ],
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _courseName = '';
    _date = DateTime.now();
    UserPreference.initPref().whenComplete(() {
      _players = [
        UserPreference.sp.getString(UserPreference.player1Name),
        UserPreference.sp.getString(UserPreference.player2Name),
        UserPreference.sp.getString(UserPreference.player3Name),
        UserPreference.sp.getString(UserPreference.player4Name),
      ];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(context),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _courseNameAndDateForm(context),
          _playerNamesForm(context),
        ],
      ),
    );
  }
}
