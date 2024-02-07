import 'package:flutter/material.dart';
//import 'package:word_puzzle/words_helper.dart';
import 'package:word_puzzle/database_helper.dart';
import 'dart:math';
import 'dart:async';

class Todo {
  final String title;
  final String description;
  Todo(this.title, this.description);
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Word Puzzle',
    home: SelectWidget(),
  ));
}

class SelectWidget extends StatefulWidget {
  const SelectWidget({super.key});
  @override
  State createState() => _SelectWidgetState();
}

double deviceWidth = 0.0;

class _SelectWidgetState extends State<SelectWidget> {
  List<ACategory> categories = [];
  List<List<AWord>> allWords = [];
  List<Color> colorList = [];

  getHeightWidth(context) {
    deviceWidth = MediaQuery.of(context).size.width;
  }

  _navigateAndDisplaySelection(BuildContext context, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GameWidget(
              category: categories[index].category,
              words: allWords[index],
              bestTime: categories[index].time)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getHeightWidth(context);
    //debugPrint(deviceWidth);
    return FutureBuilder(
      future: _initializeDatabase(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Scaffold(
/*                appBar: AppBar(
                  title: Text('Word Puzzle'),
                ),*/
              body: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  /*return ListTile(
                      leading: Icon(Icons.wb_sunny),
                      title: Text(categories[index].category),
                      subtitle: Text(categories[index].time),
                      onTap: () {
                        _navigateAndDisplaySelection(context, index);
                      },
                    );*/
                  return Container(
                      height: 100,
                      color: Colors.white,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            _navigateAndDisplaySelection(context, index);
                          },
                          hoverColor: Colors.blue,
                          child: Container(
                            margin:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                            //                        color: Colors.red,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: colorList[index % colorList.length],
                              //boxShadow: [ BoxShadow(color: Colors.pink, spreadRadius: 2), ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    Text(categories[index].category,
                                        style: const TextStyle(
                                          fontSize: 25.0,
                                          fontFamily: 'listFont',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ))
                                  ]),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          const Text("   "),
                                          const Icon(
                                              IconData(57746,
                                                  fontFamily: 'MaterialIcons'),
                                              color: Colors.white),
                                          const Text("   "),
                                          Text(categories[index].time,
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white)),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          const Icon(
                                              IconData(58683,
                                                  fontFamily: 'MaterialIcons'),
                                              color: Colors.white),
                                          Text(
                                              allWords[index].length.toString(),
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white)),
                                          const Text("   "),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ));
                },
              ),
            );
          }
        }
      },
    );
  }

  Future _initializeDatabase() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.initializeDatabase();
    int? ccount = await helper.getCategoryCount();
    int? wcount = await helper.getAllWordsCount();
    categories = await helper.getAllCategories();

    colorList.add(Colors.deepOrange[400]!);
    colorList.add(Colors.orangeAccent[400]!);
    colorList.add(Colors.purpleAccent[400]!);
    colorList.add(Colors.redAccent[400]!);
    colorList.add(Colors.lightGreen[900]!);
    colorList.add(Colors.indigoAccent);
    colorList.add(Colors.redAccent[400]!);

    for (int i = 0; i < categories.length; i++) {
      allWords.add(await helper.getWords(categories[i].category));
    }
    debugPrint("Database Loaded..  CCount : [$ccount]  WCount[$wcount]");
  }
}

List<List<String>> gridMap = [];
double gridSize = 20.0;
List<Point> touchItems = [];

List<List<Point>> foundMap = [];
List<Color> foundColor = [];
List<String> foundWords = [];

class GameWidget extends StatefulWidget {
  final String category;
  final List<AWord> words;
  final String bestTime;

  const GameWidget(
      {super.key,
      required this.category,
      required this.words,
      required this.bestTime});
  @override
  State createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  int? gridW;
  int? gridH;
  List<String> wordsList = [];

  Size? panSize;

  double x = 0.0;
  double y = 0.0;
  int timeElapsed = 10;

  final GlobalKey _keyRed = GlobalKey();
  bool? validTouchFlag;

  static const duration = Duration(seconds: 1);
  int secondsPassed = 0;
  bool isActive = false;
  Timer? timer;
  void handleTick() {
    setState(() {
      secondsPassed = secondsPassed + 1;
    });
  }

  void finishGame() {
    DatabaseHelper helper = DatabaseHelper.instance;
    helper.updateBestTime(widget.category, secondsPassed);
    timer!.cancel();

    Navigator.pop(
        context, ACategory.withTime(widget.category, secondsPassed.toString()));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Congratulations!"),
            content: Text(
                "Your Score is ${secondsPassed ~/ 60} m ${secondsPassed % 60} s"),
          );
        });
  }

  void _incrementDown(PointerEvent details) {
    _updateLocation(details);
//    finishGame();
    setState(() {
      touchItems.clear();
      validTouchFlag = true;
    });
  }

  void _incrementUp(PointerEvent details) {
    _updateLocation(details);
    String selectedStr = "";
    for (var element in touchItems) {
      selectedStr = selectedStr + gridMap[element.y.toInt()][element.x.toInt()];
    }
    if (wordsList.contains(selectedStr) && !foundWords.contains(selectedStr)) {
      foundMap.add(List<Point>.generate(
          touchItems.length, (index) => touchItems[index]));
      foundColor.add(Color.fromARGB(100, Random().nextInt(255),
          Random().nextInt(255), Random().nextInt(255)));
      foundWords.add(selectedStr);

      if (foundWords.length == wordsList.length) {
        finishGame();
      }
    }
    touchItems.clear();
  }

  void _updateLocation(PointerEvent details) {
    if (validTouchFlag == true) {
      setState(() {
        x = details.position.dx - _getPositions().dx;
        y = details.position.dy - _getPositions().dy;

        int itemX = x ~/ gridSize;
        int itemY = y ~/ gridSize;
        if (!touchItems.contains(Point(itemX, itemY)) &&
            itemX >= 0 &&
            itemX < gridW! &&
            itemY >= 0 &&
            itemY < gridH!) {
          Offset itemPos = Offset(
              itemX * gridSize + gridSize / 2, itemY * gridSize + gridSize / 2);
          Offset touchPos = Offset(x, y);
          if ((itemPos - touchPos).distance < gridSize / 2.5) {
            if (touchItems.length < 2) {
              touchItems.add(Point(itemX, itemY));
            } else if (itemX + touchItems[touchItems.length - 2].x ==
                    touchItems[touchItems.length - 1].x * 2 &&
                itemY + touchItems[touchItems.length - 2].y ==
                    touchItems[touchItems.length - 1].y * 2) {
              touchItems.add(Point(itemX, itemY));
            }
          }
        }
      });
    }
  }

  Offset _getPositions() {
    final RenderBox? renderBox =
        _keyRed.currentContext!.findAncestorRenderObjectOfType<RenderBox>();
    Offset position = renderBox!.localToGlobal(Offset.zero);
    return position;
  }

  @override
  void initState() {
    super.initState();
    foundMap.clear();
    foundColor.clear();
    foundWords.clear();
    touchItems.clear();
    _initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    timer ??= Timer.periodic(duration, (Timer t) {
      handleTick();
    });

    int seconds = secondsPassed % 60;
    int minutes = secondsPassed ~/ 60;
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.cyan,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Center(
                  child: Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.cyan[800]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Time',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.yellow[700]),
                                        child: Text(
                                          //'$timeElapsed',
                                          "$minutes:$seconds",
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ])),
                          Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.cyan[800]),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text('Best Time',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.yellow[700]),
                                        child: Text(
                                          // ignore: unnecessary_string_interpolations
                                          '${widget.bestTime}',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ])),
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Listener(
                      onPointerDown: _incrementDown,
                      onPointerMove: _updateLocation,
                      onPointerUp: _incrementUp,
                      child: Column(children: <Widget>[
                        Container(
                          width: panSize!.width,
                          height: panSize!.height,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.cyan[200]),
                          //color: Colors.white,
                          child: CustomPaint(
                              painter: CharacterMapPainter(), key: _keyRed),
                        ),
                      ])),
                ),
                SizedBox(
                    width: deviceWidth * 0.8,
                    height: (wordsList.length * 10).toDouble(),
                    child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(0),
                      //crossAxisSpacing: 10,
                      //mainAxisSpacing: 1 / 10,
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                      children: wordsList
                          .map((data) => Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 5),
                              child: Center(
                                  child: Text(data,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        //fontFamily: 'wordsFont',
                                        color: foundWords.contains(data)
                                            ? foundColor[
                                                foundWords.indexOf(data)]
                                            : Colors.black,
                                      ),
                                      textAlign: TextAlign.center))))
                          .toList(),
                    )),
              ])),
      // Inner yellow container
      /*child: */
    );
  }

  void _initializeGame() {
    gridH = 15;
    gridW = 15;
    gridSize = (deviceWidth - 20) / gridW!;
    //debugPrint(wi;

    gridMap = List<List<String>>.generate(
        gridH!, (i) => List<String>.generate(gridW!, (j) => ""));
    panSize = Size(gridW!.toDouble() * gridSize, gridH!.toDouble() * gridSize);
    wordsList = List<String>.generate(
        widget.words.length, (index) => widget.words[index].word);
    wordsList.sort((b, a) => a.length.compareTo(b.length));
    var random = Random();
    if (wordsList.isEmpty) {
      return;
    }
    var first = generate(random.nextInt(8), wordsList[0]);
    Point pt = Point(random.nextInt(gridW! - first.first.length + 1),
        random.nextInt(gridH! - first.length + 1));
    putOnGrid(first, pt);
    for (int wi = 1; wi < wordsList.length; wi++) {
      int dir;
      checkFound:
      for (dir = 0; dir < 8; dir++) {
        //find if words match exist
        var piece = generate(dir, wordsList[wi]);
        for (int i = 0; i < gridH! - piece.length; i++) {
          for (int j = 0; j < gridW! - piece.first.length; j++) {
            int matchCharCount = 0, dismatchCharCount = 0;
            for (int ii = 0; ii < piece.length; ii++) {
              for (int jj = 0; jj < piece.first.length; jj++) {
                if (piece[ii][jj] == gridMap[i + ii][j + jj] &&
                    piece[ii][jj] != "") {
                  matchCharCount++;
                } else if (piece[ii][jj] != gridMap[i + ii][j + jj] &&
                    gridMap[i + ii][j + jj] != "") {
                  dismatchCharCount++;
                }
              }
            }
            if (matchCharCount > 0 && dismatchCharCount == 0) {
              putOnGrid(piece, Point(j, i));
              break checkFound;
            }
          }
        }
      }
      if (dir == 8) {
        putAsAnother:
        while (true) {
          var piece = generate(random.nextInt(8), wordsList[wi]);
          int i = random.nextInt(gridH! - piece.length);
          int j = random.nextInt(gridW! - piece.first.length);
          int matchCharCount = 0;
          for (int ii = 0; ii < piece.length; ii++)
{            for (int jj = 0; jj < piece.first.length; jj++) {
              if (gridMap[i + ii][j + jj] != "") {
                matchCharCount++;
              }
            }
}          if (matchCharCount == 0) {
            putOnGrid(piece, Point(j, i));
            break putAsAnother;
          }
        }
      }
    }

    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < gridMap.length; i++)
      {for (int j = 0; j < gridMap[i].length; j++) {
        if (gridMap[i][j] == "") {
          gridMap[i][j] = chars[random.nextInt(26)];
        }
      }}
  }

  void putOnGrid(List<List<String>> piece, Point pt) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        gridMap[pt.y.toInt() + i][pt.x.toInt() + j] = piece[i][j];
      }
    }
  }

  List<List<String>> generate(int direction, String aword) {
    List<List<String>> grid = [];
    if (direction == 0) {
      grid = List<List<String>>.generate(
          1, (i) => List<String>.generate(aword.length, (j) => aword[j]));
    } else if (direction == 1) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i == j ? aword[i] : ""));
    } else if (direction == 2) {
      grid = List<List<String>>.generate(
          aword.length, (i) => List<String>.generate(1, (j) => aword[i]));
    } else if (direction == 3) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i + j + 1 == aword.length ? aword[i] : ""));
    } else if (direction == 4) {
      grid = List<List<String>>.generate(
          1,
          (i) => List<String>.generate(
              aword.length, (j) => aword[aword.length - 1 - j]));
    } else if (direction == 5) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i == j ? aword[aword.length - i - 1] : ""));
    } else if (direction == 6) {
      grid = List<List<String>>.generate(aword.length,
          (i) => List<String>.generate(1, (j) => aword[aword.length - i - 1]));
    } else if (direction == 7) {
      grid = List<List<String>>.generate(
          aword.length,
          (i) => List<String>.generate(
              aword.length, (j) => i + j + 1 == aword.length ? aword[j] : ""));
    }
    return grid;
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }
}

class CharacterMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.cyan[200]!;
    // Left eye
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(10)),
        paint);
    for (int i = 0; i < gridMap.length; i++)
      {for (int j = 0; j < gridMap[i].length; j++) {
        final textStyle = TextStyle(
            color: Colors.cyan[900], fontSize: 16, fontWeight: FontWeight.bold);
        final textSpan = TextSpan(text: gridMap[i][j], style: textStyle);
        final textPainter =
            TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout();
        final offset = Offset(j * gridSize + (gridSize - textPainter.width) / 2,
            i * gridSize + (gridSize - textPainter.height) / 2);
        textPainter.paint(canvas, offset);
      }}
    //----- Found Words history
    List<Offset> offset = [];
    Path path = Path();
    paint.strokeWidth = gridSize;
    paint.strokeCap = StrokeCap.round;
    paint.strokeJoin = StrokeJoin.round;
    for (int i = 0; i < foundWords.length; i++) {
      offset.clear();
      path.reset();
      paint.color = foundColor[i];
      for (int j = 0; j < foundMap[i].length; j++) {
        offset.add(Offset(foundMap[i][j].x * gridSize + gridSize / 2,
            foundMap[i][j].y * gridSize + gridSize / 2));
      }
      path.addPolygon(offset, false);
      canvas.drawPath(path, paint);
    }

    //----- Current drawing
    List<Offset> offsets = [];
    for (int i = 0; i < touchItems.length; i++) {
      offsets.add(Offset(touchItems[i].x * gridSize + gridSize / 2,
          touchItems[i].y * gridSize + gridSize / 2));
    }
    path.reset();
    path.addPolygon(offsets, false);
    paint.color = const Color.fromRGBO(255, 0, 0, 80);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CharacterMapPainter oldDelegate) => true;
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
