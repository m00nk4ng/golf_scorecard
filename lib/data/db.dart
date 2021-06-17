/*
 * This singleton class will have the instance of the database.
 */

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'model.dart';

class DB {
  // database file name and version
  static final String _dbName = 'scorecard.db';
  static final int _dbVersion = 1;

  // table name in database
  static final String _gameTable = 'game_table';
  static final String _playerTable = 'card_table';

  // column names in database
  static final String columnGameID = 'game_id';
  static final String columnCourseName = 'course_name';
  static final String columnDate = 'date';
  static final String columnPar = 'pars';

  static final String columnPlayerID = 'player_id';
  static final String columnGameFK = 'game_fk';
  static final String columnPlayer = 'player';
  static final String columnScore = 'score';

  DB._privateConstructor();

  static final DB instance = DB._privateConstructor();

  static Database _database;

  // return database object
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDB();
    return _database;
  }

  // Initialize the database.
  _initDB() async {
    String path = join(await getDatabasesPath(), _dbName);
    print(path);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // Create database if does not exist
  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
        CREATE TABLE $_gameTable (
          $columnGameID INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnCourseName TEXT,
          $columnDate TEXT,
          $columnPar TEXT
        )
      ''',
    );

    await db.execute(
      '''
        CREATE TABLE $_playerTable (
          $columnPlayerID INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnGameFK INTEGER,
          $columnPlayer TEXT,
          $columnScore TEXT
        )
      ''',
    );
  }

  // Query all games
  Future<List<Map<String, dynamic>>> getAllGames() async {
    Database db = await instance.database;
    return await db.query(_gameTable);
  }

  // Query game using id
  Future<List<Map<String, dynamic>>> getGameID(int id) async {
    Database db = await instance.database;
    return await db.query(
      _gameTable,
      where: '$columnGameID = ?',
      whereArgs: [id],
    );
  }

  // Query game using id
  Future<List<Map<String, dynamic>>> getPlayerID(int id) async {
    Database db = await instance.database;

    return await db.query(
      _playerTable,
      where: '$columnGameFK = ?',
      whereArgs: [id],
    );
  }

  // Insert new game
  Future<int> insertGame(Game game) async {
    Database db = await instance.database;
    return await db.insert(_gameTable, game.toMap());
  }

  // Insert new player
  Future<int> insertPlayer(Player player) async {
    Database db = await instance.database;
    return await db.insert(_playerTable, player.toMap());
  }

  // Delete game
  Future<int> deleteGame(Game game) async {
    Database db = await instance.database;
    await db.delete(
      _playerTable,
      where: '$columnGameFK = ?',
      whereArgs: [game.iD],
    );
    return await db.delete(
      _gameTable,
      where: '$columnGameID = ?',
      whereArgs: [game.iD],
    );
  }

  // Delete player
  Future<int> deletePlayer(Player player) async {
    Database db = await instance.database;
    return await db.delete(
      _playerTable,
      where: '$columnGameFK = ? AND $columnPlayer = ?',
      whereArgs: [player.fK, player.playerName],
    );
  }

  // Update game
  Future<int> updateGame(Game game) async {
    Database db = await instance.database;
    return await db.update(
      _gameTable,
      game.toMap(),
      where: '$columnGameID = ?',
      whereArgs: [game.iD],
    );
  }

  // Update player
  Future<int> updatePlayer(Player player) async {
    Database db = await instance.database;
    return await db.update(
      _playerTable,
      player.toMap(),
      where: '$columnPlayerID = ?',
      whereArgs: [player.iD],
    );
  }
}
