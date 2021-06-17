import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:golf_scorecard/data/data.dart';
import 'package:golf_scorecard/ui/screens/scorecard_screen.dart';
import 'package:golf_scorecard/ui/widget/custom_panel.dart';

class ScoreHistoryScreen extends StatefulWidget {
  final String title;

  ScoreHistoryScreen({this.title});

  @override
  _ScoreHistoryScreenState createState() => _ScoreHistoryScreenState();
}

class _ScoreHistoryScreenState extends State<ScoreHistoryScreen> {
  // State Variables
  Future<List<Map>> _scoreCardList;
  bool _dateSort = true;
  bool _increasing = false;

  // Functions
  _loadData() {
    _scoreCardList = DB.instance.getAllGames();
  }

  _sortByDate(List list) {
    List sortedList = [];
    sortedList.addAll(list);
    if (_increasing)
      sortedList.sort((a, b) => DateTime.parse(a[DB.columnDate])
          .compareTo(DateTime.parse(b[DB.columnDate])));
    else
      sortedList.sort((b, a) => DateTime.parse(a[DB.columnDate])
          .compareTo(DateTime.parse(b[DB.columnDate])));
    return sortedList;
  }

  _sortByName(List list) {
    List sortedList = [];
    sortedList.addAll(list);
    if (_increasing)
      sortedList.sort((a, b) =>
          (a[DB.columnCourseName].toString().toLowerCase())
              .compareTo((b[DB.columnCourseName]).toString().toLowerCase()));
    else
      sortedList.sort((b, a) =>
          (a[DB.columnCourseName].toString().toLowerCase())
              .compareTo((b[DB.columnCourseName]).toString().toLowerCase()));
    return sortedList;
  }

  // Widgets
  Widget get _appBar => AppBar(
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
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.ellipsis),
            color: Colors.grey[850],
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(7.0)),
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        leading: null,
                        title: (Text(
                          'Sort By',
                          style: TextStyle(
                            color: Colors.grey[850],
                            fontWeight: FontWeight.w300,
                          ),
                        )),
                        elevation: 0.7,
                      ),
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('Date (Old to New)'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _dateSort = true;
                                _increasing = true;
                              });
                            },
                          ),
                          ListTile(
                            title: Text('Date (New to Old)'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _dateSort = true;
                                _increasing = false;
                              });
                            },
                          ),
                          ListTile(
                            title: Text('Name (A-Z)'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _dateSort = false;
                                _increasing = true;
                              });
                            },
                          ),
                          ListTile(
                            title: Text('Name (Z-A)'),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _dateSort = false;
                                _increasing = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  Widget _body(context) => SafeArea(
        child: FutureBuilder(
          future: _scoreCardList,
          initialData: [],
          builder: (context, AsyncSnapshot<List> _scoreCards) {
            List sortedList;
            if (_scoreCards.hasData && _dateSort)
              sortedList = _sortByDate(_scoreCards.data);
            else if (_scoreCards.hasData)
              sortedList = _sortByName(_scoreCards.data);
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScorecardScreen(
                                id: sortedList[index][DB.columnGameID],
                                courseName: sortedList[index]
                                    [DB.columnCourseName],
                                onPop: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _loadData();
                                  });
                                },
                              ),
                            ),
                          ).then((value) {
                            setState(() {
                              _loadData();
                            });
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: CustomPanel(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sortedList[index][DB.columnCourseName],
                                    ),
                                    Text(sortedList[index][DB.columnDate]
                                        .toString()
                                        .substring(0, 10)),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(CupertinoIcons.trash),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Text('Delete Game'),
                                        content: Text(
                                            'Are you sure you want to delete this game?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await DB.instance.deleteGame(
                                                  Game.fromMap(
                                                      sortedList[index]));
                                              setState(() {
                                                _loadData();
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red[600])),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Cancel',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: sortedList.length,
                  ),
                )
              ],
            );
          },
        ),
      );

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: _body(context),
    );
  }
}
