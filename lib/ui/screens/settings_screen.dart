import 'package:flutter/material.dart';
import 'package:golf_scorecard/data/user_preference.dart';

enum DisplayMethod { Par, Stroke }

class SettingsScreen extends StatefulWidget {
  final String title;

  SettingsScreen({this.title});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );

  Widget _switchList({String label, bool value, Function onChanged}) {
    return ListTile(
      title: Text(label),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget get _radioList {
    return ListTile(
      title: Text('Stroke or Par'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Par'),
          Radio(
            value: false,
            groupValue: UserPreference.sp.getBool(UserPreference.showAsStroke),
            onChanged: (value) async {
              setState(() {
                UserPreference.sp.setBool(UserPreference.showAsStroke, value);
              });
            },
          ),
          Text('Stroke'),
          Radio(
            value: true,
            groupValue: UserPreference.sp.getBool(UserPreference.showAsStroke),
            onChanged: (value) async {
              setState(() {
                UserPreference.sp.setBool(UserPreference.showAsStroke, value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget get _player1List {
    return ListTile(
      title: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        initialValue: UserPreference.sp.getString(UserPreference.player1Name),
        decoration: InputDecoration(
          labelText: 'Your Name',
          hintText: 'Me',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.trim().isEmpty)
            UserPreference.sp.setString(UserPreference.player1Name, 'Me');
          else
            UserPreference.sp
                .setString(UserPreference.player1Name, value.trim());
        },
      ),
    );
  }

  Widget _playerList({
    String labelText,
    String initialValue,
    Function onChanged,
  }) {
    return ListTile(
      title: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget get _body => ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            _switchList(
              label: 'Show Circle for under Par',
              value: UserPreference.sp.getBool(UserPreference.showCircle),
              onChanged: (value) async {
                setState(() {
                  UserPreference.sp.setBool(UserPreference.showCircle, value);
                });
              },
            ),
            _switchList(
              label: 'Show Square for above Par',
              value: UserPreference.sp.getBool(UserPreference.showSquare),
              onChanged: (value) async {
                setState(() {
                  UserPreference.sp.setBool(UserPreference.showSquare, value);
                });
              },
            ),
            _radioList,
            _player1List,
            _playerList(
              labelText: 'Default golfer 2',
              initialValue:
                  UserPreference.sp.getString(UserPreference.player2Name),
              onChanged: (value) {
                setState(() {
                  UserPreference.sp
                      .setString(UserPreference.player2Name, value.trim());
                });
              },
            ),
            _playerList(
              labelText: 'Default golfer 3',
              initialValue:
                  UserPreference.sp.getString(UserPreference.player3Name),
              onChanged: (value) {
                setState(() {
                  UserPreference.sp
                      .setString(UserPreference.player3Name, value.trim());
                });
              },
            ),
            _playerList(
              labelText: 'Default golfer 4',
              initialValue:
                  UserPreference.sp.getString(UserPreference.player4Name),
              onChanged: (value) {
                setState(() {
                  UserPreference.sp
                      .setString(UserPreference.player4Name, value.trim());
                });
              },
            ),
          ],
        ).toList(),
      );

  @override
  void initState() {
    UserPreference.initPref().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: _appBar,
        body: _body,
      ),
    );
  }
}
