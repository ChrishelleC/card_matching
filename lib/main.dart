import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => GameProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstFlipped;
  bool isChecking = false;
  int score = 0;
  int timeElapsed = 0;
  Timer? timer;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<String> images = ["assets/card1.png", "assets/card2.png", "assets/card3.png", "assets/card4.png"];
    images = [...images, ...images]; // Duplicate for matching pairs
    images.shuffle();
    cards = images.map((img) => CardModel(image: img)).toList();
    startTimer();
  }

  void flipCard(CardModel card) {
    if (isChecking || card.isFaceUp || card.isMatched) return;

    card.isFaceUp = true;
    notifyListeners();

    if (firstFlipped == null) {
      firstFlipped = card;
    } else {
      isChecking = true;
      Future.delayed(Duration(seconds: 1), () {
        if (firstFlipped!.image == card.image) {
          firstFlipped!.isMatched = true;
          card.isMatched = true;
          score += 10;
        } else {
          firstFlipped!.isFaceUp = false;
          card.isFaceUp = false;
          score -= 5;
        }
        firstFlipped = null;
        isChecking = false;
        notifyListeners();
        checkWin();
      });
    }
  }

  void startTimer() {
    timer?.cancel();
    timeElapsed = 0;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeElapsed++;
      notifyListeners();
    });
  }

  void checkWin() {
    if (cards.every((card) => card.isMatched)) {
      timer?.cancel();
      // Show win message
    }
  }
}

class CardModel {
  final String image;
  bool isFaceUp;
  bool isMatched;

  CardModel({required this.image, this.isFaceUp = false, this.isMatched = false});
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: Column(
        children: [
          Consumer<GameProvider>(
            builder: (context, game, child) => Column(
              children: [
                Text("Score: ${game.score}"),
                Text("Time: ${game.timeElapsed}s"),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GameProvider>(
              builder: (context, game, child) => GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                itemCount: game.cards.length,
                itemBuilder: (context, index) {
                  CardModel card = game.cards[index];
                  return GestureDetector(
                    onTap: () => game.flipCard(card),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: card.isFaceUp
                          ? Image.asset(card.image, key: ValueKey(card.image))
                          : Image.asset("assets/back.png", key: ValueKey("back")),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
