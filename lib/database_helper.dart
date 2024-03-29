import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
const String databaseName = 'Word-Puzzle.db';
const String tableCategories = 'categories';
const String tableWords = 'words';

const String columnCategory = 'category';
const String columnTime = 'time';
const String columnWord = 'word';

// data model class
class ACategory {
  String category;
  String time;
  ACategory(this.category, {this.time = "00:00"});
  ACategory.withTime(this.category, this.time) {
    category = category;
    time = time;
  }
  ACategory.empty() : this("");

  factory ACategory.fromMap(Map<dynamic, dynamic> map) {
    return ACategory(map[columnCategory], time: map[columnTime]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnCategory: category, columnTime: time};
    return map;
  }
}

class AWord {
  String category;
  String word;
  AWord(this.category, this.word);

  factory AWord.fromMap(Map<String, dynamic> map) =>
      AWord(map[columnCategory],map[columnWord]);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnCategory: category, columnWord: word};
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  static const _databaseName = databaseName;
  static const _databaseVersion = 1;
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async {
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableCategories (
            $columnCategory TEXT PRIMARY KEY,
            $columnTime TEXT DEFAULT '0.0s'
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableWords (
            $columnCategory TEXT NOT NULL,
            $columnWord TEXT NOT NULL
          )
          ''');
  }

  // Database helper methods:
  Future<bool> databaseExists(String path) =>
      databaseFactory.databaseExists(path);
  Future<int> initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    bool isExist = await databaseExists(path);

    if (isExist) return 0;

    debugPrint("Initializing database");
    Database db = await database;
    await db.rawQuery('delete from $tableCategories');
    await db.rawQuery('delete from $tableWords');
    List<String> cats = [
      'Face',
      'Fruits',
      'Vegetables',
      'Colors',
      'Occupations',
      'Musical Instruments',
      'Flowers',
      'Bar',
      'Bathroom',
      'House',
      'Makeup',
      'Family'
    ];
    List<String> wface = [
      'hair',
      'skin',
      'eyebrow',
      'eyelash',
      'ear',
      'nose',
      'mole',
      'lip',
      'chin',
      'forehead',
      'temple',
      'eye',
      'cheek',
      'nostril',
      'mouth'
    ];
    List<String> wfruits = [
      'orange',
      'lime',
      'lemon',
      'apricot',
      'watermelon',
      'grapes',
      'raspberry',
      'blackberry',
      'strawberry',
      'grapefruit',
      'peach',
      'plum',
      'mango',
      'banana',
      'papaya'
    ];
    List<String> wvegetables = [
      'corn',
      'green bean',
      'lettuce',
      'cucumber',
      'zucchini',
      'pumpkin',
      'pepper',
      'carrot',
      'asparagus',
      'potato',
      'onion',
      'artichoke',
      'radish',
      'broccoli',
      'celery'
    ];
    List<String> wcolors = [
      'red',
      'blue',
      'green',
      'yellow',
      'orange',
      'purple',
      'teal',
      'pink',
      'gray',
      'white',
      'black',
      'brown'
    ];
    List<String> woccupations = [
      'lawyer',
      'accountant',
      'scientist',
      'teacher',
      'pilot',
      'doctor',
      'actress',
      'dancer',
      'musician',
      'photographer',
      'painter',
      'librarian',
      'receptionist',
      'travel agent',
      'journalist'
    ];
    List<String> wmusical = [
      'piano',
      'saxophone',
      'guitar',
      'violin',
      'viola',
      'harp',
      'cello',
      'french horn',
      'tuba',
      'drum',
      'trumpet',
      'keyboard',
      'mandolin',
      'bass',
      'flute'
    ];
    List<String> wflowers = [
      'lily',
      'flowers',
      'carnation',
      'tulip',
      'orchid',
      'gladiolus',
      'daisy',
      'acacia',
      'chrysanthemum',
      'iris',
      'rose',
      'freesia',
      'gerbera'
    ];
    List<String> wbar = [
      'martini',
      'cocktail',
      'wine',
      'beer',
      'gin',
      'whiskey',
      'scotch',
      'rum'
    ];
    List<String> wbathroom = [
      'sink',
      'bathtub',
      'shower',
      'shower head',
      'toilet',
      'toilet brush',
      'drain',
      'sponge',
      'deoderant',
      'mouthwash',
      'toothpaste',
      'toothbrush',
      'aftershave',
      'soap',
      'bubble bath'
    ];
    List<String> whouse = [
      'window',
      'front door',
      'chimney',
      'roof',
      'sidewalk',
      'gutter',
      'dormer window',
      'shutter',
      'porch',
      'shingle',
      'balcony',
      'foyer',
      'doorbell',
      'hand rail',
      'staircase'
    ];
    List<String> wmakeup = [
      'hair dye',
      'eyeshadow',
      'mascara',
      'eyeliner',
      'blusher',
      'foundation',
      'lipstick',
      'lip gloss',
      'face powder',
      'tweezers',
      'mirror',
      'concealer',
      'brush',
      'lip liner'
    ];
    List<String> wfamily = [
      'grandmother',
      'grandfather',
      'mother',
      'father',
      'uncle',
      'aunt',
      'brother',
      'sister',
      'son',
      'daughter',
      'cousin',
      'grandson',
      'granddaughter',
      'niece',
      'nephew'
    ];

    for (int i = 0; i < cats.length; i++) {
      await db.insert(tableCategories, ACategory(cats[i]).toMap());
    }
    for (int i = 0; i < wface.length; i++) {
      await db.insert(tableWords,
          AWord('Face', wface[i].toUpperCase().replaceAll(" ", "")).toMap());
    }
    for (int i = 0; i < wfruits.length; i++) {
      await db.insert(
          tableWords,
          AWord('Fruits', wfruits[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wvegetables.length; i++) {
      await db.insert(
          tableWords,
          AWord('Vegetables', wvegetables[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wcolors.length; i++) {
      await db.insert(
          tableWords,
          AWord('Colors', wcolors[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < woccupations.length; i++) {
      await db.insert(
          tableWords,
          AWord('Occupations',
                  woccupations[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wmusical.length; i++) {
      await db.insert(
          tableWords,
          AWord('Musical Instruments',
                  wmusical[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wflowers.length; i++) {
      await db.insert(
          tableWords,
          AWord('Flowers', wflowers[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wbar.length; i++) {
      await db.insert(tableWords,
          AWord('Bar', wbar[i].toUpperCase().replaceAll(" ", "")).toMap());
    }
    for (int i = 0; i < wbathroom.length; i++) {
      await db.insert(
          tableWords,
          AWord('Bathroom', wbathroom[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < whouse.length; i++) {
      await db.insert(tableWords,
          AWord('House', whouse[i].toUpperCase().replaceAll(" ", "")).toMap());
    }
    for (int i = 0; i < wmakeup.length; i++) {
      await db.insert(
          tableWords,
          AWord('Makeup', wmakeup[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    for (int i = 0; i < wfamily.length; i++) {
      await db.insert(
          tableWords,
          AWord('Family', wfamily[i].toUpperCase().replaceAll(" ", ""))
              .toMap());
    }
    return 1;
  }

  Future<void> dropTables() async {
    Database db = await database;
    await db.rawQuery('drop table $tableCategories');
    await db.rawQuery('drop table $tableWords');
  }

  Future<int> insert(ACategory word) async {
    Database db = await database;
    int id = await db.insert(tableCategories, word.toMap());
    return id;
  }

  Future<ACategory?> queryCategory(String category) async {
    Database db = await database;
    List<Map> maps = await db.query(tableCategories,
        columns: [columnCategory, columnTime],
        where: '$columnCategory = ?',
        whereArgs: [category]);
    if (maps.isNotEmpty) {
      return ACategory.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ACategory>> getAllCategories() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableCategories);
    return List.generate(maps.length, (i) {
      return ACategory.withTime(maps[i]['category'], maps[i]['time']);
    });
  }

  Future<List<AWord>> getWords(String category) async {
    final Database db = await database;
    List<Map> maps = await db.query(tableWords,
        columns: [columnCategory, columnWord],
        where: '$columnCategory = ?',
        whereArgs: [category]);
    return List.generate(maps.length, (i) {
      return AWord(maps[i]['category'], maps[i]['word']);
    });
  }

  Future<int?> getCategoryCount() async {
    //database connection
    Database db = await database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableCategories');
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<int?> getAllWordsCount() async {
    //database connection
    Database db = await database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableWords');
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<int> delete(String c) async {
    final db = await database;
    var result =
        await db.delete(tableCategories, where: 'category = ?', whereArgs: [c]);
    return result;
  }

  Future<int> updateBestTime(String cat, int secs) async {
    final db = await database;
    ACategory? last = await queryCategory(cat);
    debugPrint("${last!.category} - ${last.time}");
    int lastSec = int.parse(last.time.split(':')[1]) +
        int.parse(last.time.split(':')[0]) * 60;

    debugPrint("$lastSec $secs");
    if (lastSec > secs || lastSec == 0) {
      String mm = secs ~/ 60 < 10
          ? "0${secs ~/ 60}"
          : (secs ~/ 60).toString();
      String ss = secs % 60 < 10
          ? "0${secs % 60}"
          : (secs % 60).toString();
      return await db.update(
        tableCategories,
        ACategory.withTime(cat, "$mm:$ss").toMap(),
        where: "category = ?",
        whereArgs: [cat],
      );
    }
    return 0;
  }
}
