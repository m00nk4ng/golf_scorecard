import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:golf_scorecard/data/data.dart';
import 'package:golf_scorecard/ui/constant.dart';

class ScorecardScreen extends StatefulWidget {
  final int id;
  final String courseName;
  final Function onPop;

  ScorecardScreen({this.id, this.courseName, this.onPop});

  @override
  _ScorecardScreenState createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  final double _height = 50;

  // State Variables
  String _title;
  Future<List<Map>> _game;
  Future<List<Map>> _players;
  bool _selected = false;
  int _selectedX;
  int _selectedY;
  Game _currentGame;
  Player _selectedPlayer;

  // update database and set state
  _updateDB() async {
    setState(() {
      _game = DB.instance.getGameID(widget.id);
      _players = DB.instance.getPlayerID(widget.id);
    });
  }

  // Widget
  Widget get _appBar => AppBar(
        title: GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('Enter Course Name'),
              content: TextFormField(
                initialValue: _title,
                onChanged: (value) => _title =
                    (value.trim() == '') ? 'Untitled Golf Course' : value,
                decoration: InputDecoration(hintText: 'Untitled Golf Course'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _currentGame.courseName = _title;
                    DB.instance.updateGame(_currentGame);
                    _updateDB();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text('Confirm'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),
          child: Text(
            _title,
            style: TextStyle(
              color: Colors.grey[850],
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        elevation: 0.7,
        leading: BackButton(
          color: Colors.grey[850],
          onPressed: widget.onPop,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  Widget get _body => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: FutureBuilder(
            future: Future.wait([_game, _players]),
            builder: (context, AsyncSnapshot<List<List<Map>>> snapshot) {
              if (snapshot.hasData) {
                Map gameInfo = snapshot.data[0].first;
                List<Map> playerInfo = snapshot.data[1];
                return Column(
                  children: [
                    Text(
                      gameInfo[DB.columnDate].toString().substring(0, 11),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    _table(gameInfo, playerInfo),
                  ],
                );
              }
              return Container(
                  // child: Text('loading'),
                  );
            },
          ),
        ),
      );

  Widget _table(Map courseData, List<Map> playerData) {
    _currentGame = Game.fromMap(courseData);
    List<TableRow> tableRows = [];

    // Title Row
    List<Widget> titleRowChild = [
      Container(
        color: Colors.green,
        height: _height,
        child: Center(child: Text('Hole', style: kWhiteTextStyle)),
      ),
      Container(
        color: Colors.grey[850],
        height: _height,
        child: Center(child: Text('Par', style: kWhiteTextStyle)),
      ),
    ];
    for (int i = 0; i < playerData.length; i++) {
      titleRowChild.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selected = false;
              _selectedX = null;
              _selectedY = null;
            });
            Player player = Player.fromMap(playerData[i]);
            String newName = playerData[i][DB.columnPlayer];
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Enter Name'),
                content: TextFormField(
                  initialValue: playerData[i][DB.columnPlayer],
                  onChanged: (value) {
                    newName = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      player.playerName = newName.trim() == ''
                          ? 'Golfer ${i + 1}'
                          : newName.trim();
                      DB.instance.updatePlayer(player);
                      Navigator.pop(context);
                      setState(() {
                        _updateDB();
                      });
                    },
                    child: Text('Confirm'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.red[600])),
                  ),
                ],
              ),
            );
          },
          child: Container(
            color: Colors.grey[850],
            height: _height,
            child: Center(
              child: Text(
                playerData[i][DB.columnPlayer],
                style: kWhiteTextStyle,
              ),
            ),
          ),
        ),
      );
    }
    tableRows.add(TableRow(children: titleRowChild));

    // Out Rows
    tableRows.addAll(_subTable(courseData, playerData, 0, 9, 'Out'));

    // In Rows
    tableRows.addAll(_subTable(courseData, playerData, 9, 18, 'In'));

    // Total Row
    tableRows.addAll(_totalTable(courseData, playerData, 'Tot'));

    return Table(
      border: TableBorder.symmetric(
        inside: BorderSide(
          width: 0.5,
          color: Colors.grey[350],
        ),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(flex: 0.5),
        1: IntrinsicColumnWidth(flex: 0.6),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
        4: FlexColumnWidth(),
        5: FlexColumnWidth(),
      },
      children: tableRows,
    );
  }

  List<TableRow> _subTable(
    Map courseData,
    List<Map> playerData,
    int start,
    int end,
    String title,
  ) {
    List<TableRow> toBeReturned = [];
    List<int> playerStrokeTotal = [0, 0, 0, 0];
    List<int> playerTotal = [0, 0, 0, 0];
    int parTotal = 0;
    for (int i = start; i < end; i++) {
      int par = int.parse(courseData[DB.columnPar].split(',')[i]);
      parTotal += par;
      List<Widget> rowChild = [
        Container(
          height: _height,
          color: Colors.green,
          child:
              Center(child: Text((i + 1).toString(), style: kWhiteTextStyle)),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_selected && _selectedX == 0 && _selectedY == i) {
                _selected = false;
                _selectedX = null;
                _selectedY = null;
              } else {
                _selected = true;
                _selectedX = 0;
                _selectedY = i;
              }
            });
          },
          child: Container(
            height: _height,
            color: (0 == _selectedX && i == _selectedY)
                ? Colors.green[200]
                : Colors.grey[850],
            child: Center(
              child: Text(
                par.toString(),
                style: (0 == _selectedX && i == _selectedY)
                    ? kBlackTextStyle
                    : kWhiteTextStyle,
              ),
            ),
          ),
        ),
      ];
      for (int j = 0; j < playerData.length; j++) {
        int playerHoleScore =
            int.parse(playerData[j][DB.columnScore].split(',')[i]);
        playerStrokeTotal[j] += playerHoleScore;
        if (playerHoleScore != 0) playerTotal[j] += playerHoleScore - par;
        rowChild.add(
          GestureDetector(
            onTap: () {
              setState(() {
                if (_selected && _selectedX == j + 1 && _selectedY == i) {
                  _selected = false;
                  _selectedX = null;
                  _selectedY = null;
                  _selectedPlayer = null;
                } else {
                  _selected = true;
                  _selectedX = j + 1;
                  _selectedY = i;
                  _selectedPlayer = Player.fromMap(playerData[j]);
                }
              });
            },
            child: Container(
              height: _height,
              color: (j + 1 == _selectedX && i == _selectedY)
                  ? Colors.green[200]
                  : Colors.grey[50],
              child: Center(
                child: Stack(
                  children: [
                    (playerHoleScore < par &&
                            playerHoleScore != 0 &&
                            UserPreference.sp
                                .getBool(UserPreference.showCircle))
                        ? Center(
                            child: Container(
                              height: _height - 10,
                              width: _height - 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(_height),
                                border:
                                    Border.all(width: 1, color: Colors.green),
                              ),
                            ),
                          )
                        : Container(),
                    (playerHoleScore > par &&
                            UserPreference.sp
                                .getBool(UserPreference.showSquare))
                        ? Center(
                            child: Container(
                              height: _height - 10,
                              width: _height - 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border:
                                    Border.all(width: 1, color: Colors.green),
                              ),
                            ),
                          )
                        : Container(),
                    Center(
                      child: Text(
                        playerHoleScore == 0
                            ? '-'
                            : (UserPreference.sp
                                    .getBool(UserPreference.showAsStroke)
                                ? playerHoleScore.toString()
                                : (playerHoleScore - par).toString()),
                        style: kBlackTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      toBeReturned.add(TableRow(children: rowChild));
    }
    List<Widget> rowChild = [
      Container(
        height: _height,
        color: Colors.green,
        child: Center(child: Text(title, style: kWhiteTextStyle)),
      ),
      Container(
        height: _height,
        color: Colors.grey[850],
        child: Center(child: Text(parTotal.toString(), style: kWhiteTextStyle)),
      ),
    ];
    for (int i = 0; i < playerData.length; i++) {
      rowChild.add(
        Container(
          height: _height,
          color: Colors.grey[850],
          child: Center(
            child: Text(
              playerStrokeTotal[i] == 0
                  ? '-'
                  : (UserPreference.sp.getBool(UserPreference.showAsStroke)
                      ? playerStrokeTotal[i].toString()
                      : playerTotal[i].toString()),
              style: kWhiteTextStyle,
            ),
          ),
        ),
      );
    }
    toBeReturned.add(TableRow(children: rowChild));

    return toBeReturned;
  }

  List<TableRow> _totalTable(
    Map courseData,
    List<Map> playerData,
    String title,
  ) {
    List<TableRow> toBeReturned = [];
    List<int> playerTotal = [0, 0, 0, 0];
    List<int> playerStrokeTotal = [0, 0, 0, 0];

    int parTotal = 0;
    for (int i = 0; i < 18; i++) {
      int par = int.parse(courseData[DB.columnPar].split(',')[i]);
      parTotal += par;
      for (int j = 0; j < playerData.length; j++) {
        int playerHoleScore =
            int.parse(playerData[j][DB.columnScore].split(',')[i]);
        playerStrokeTotal[j] += playerHoleScore;
        if (playerHoleScore != 0) playerTotal[j] += playerHoleScore - par;
      }
    }

    List<Widget> rowChild = [
      Container(
        height: _height,
        color: Colors.green,
        child: Center(child: Text(title, style: kWhiteTextStyle)),
      ),
      Container(
        height: _height,
        color: Colors.grey[850],
        child: Center(child: Text(parTotal.toString(), style: kWhiteTextStyle)),
      ),
    ];
    for (int i = 0; i < playerData.length; i++) {
      rowChild.add(
        Container(
          height: _height,
          color: Colors.green,
          child: Center(
            child: Text(
              playerStrokeTotal[i] == 0
                  ? '-'
                  : (UserPreference.sp.getBool(UserPreference.showAsStroke)
                      ? playerStrokeTotal[i].toString()
                      : playerTotal[i].toString()),
              style: kWhiteTextStyle,
            ),
          ),
        ),
      );
    }
    toBeReturned.add(TableRow(children: rowChild));

    return toBeReturned;
  }

  Widget get _floatingActionButton => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.red[600],
            heroTag: null,
            child: Icon(CupertinoIcons.refresh_thin),
            onPressed: () {
              setState(() {
                if (_selectedX != 0) {
                  _selectedPlayer.resetScore(_selectedY);
                  DB.instance.updatePlayer(_selectedPlayer);
                  _updateDB();
                } else {
                  _currentGame.resetPar(_selectedY);
                  DB.instance.updateGame(_currentGame);
                  _updateDB();
                }
              });
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(CupertinoIcons.plus),
            onPressed: () {
              setState(() {
                if (_selectedX != 0) {
                  if (_selectedPlayer.getScore(_selectedY) == 0) {
                    _selectedPlayer.setScore(
                        _currentGame.getPar(_selectedY), _selectedY);
                  } else {
                    _selectedPlayer.incrementScore(1, _selectedY);
                  }
                  DB.instance.updatePlayer(_selectedPlayer);
                  _updateDB();
                } else {
                  _currentGame.updatePar(1, _selectedY);
                  DB.instance.updateGame(_currentGame);
                  _updateDB();
                }
              });
            },
          ),
          FloatingActionButton(
            heroTag: null,
            child: Icon(CupertinoIcons.minus),
            onPressed: () {
              setState(() {
                if (_selectedX != 0) {
                  if (_selectedPlayer.getScore(_selectedY) == 0) {
                    _selectedPlayer.setScore(
                        _currentGame.getPar(_selectedY), _selectedY);
                  } else if (_selectedPlayer.getScore(_selectedY) > 1)
                    _selectedPlayer.incrementScore(-1, _selectedY);
                  DB.instance.updatePlayer(_selectedPlayer);
                  _updateDB();
                } else {
                  _currentGame.updatePar(-1, _selectedY);
                  DB.instance.updateGame(_currentGame);
                  _updateDB();
                }
              });
            },
          ),
          FloatingActionButton(
            backgroundColor: Colors.grey[850],
            heroTag: null,
            child: Icon(CupertinoIcons.xmark),
            onPressed: () {
              setState(() {
                _selected = false;
                _selectedX = null;
                _selectedY = null;
              });
            },
          ),
        ],
      );

  @override
  void initState() {
    _updateDB();
    UserPreference.initPref().whenComplete(() {
      setState(() {});
    });
    _title = widget.courseName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = false;
          _selectedX = null;
          _selectedY = null;
        });
      },
      child: Scaffold(
        floatingActionButton: _selected ? _floatingActionButton : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        appBar: _appBar,
        body: _body,
      ),
    );
  }
}
