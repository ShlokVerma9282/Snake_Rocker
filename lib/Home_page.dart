import 'dart:async';
import 'dart:math';

import 'Package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:snake_ocker/blank_pixel.dart';
import 'package:snake_ocker/highscore_title.dart';
import 'package:snake_ocker/snake_pixel.dart';
import 'package:snake_ocker/food_pixel.dart';
import 'package:snake_ocker/highscore_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
enum Snake_Direction{UP, DOWN, LEFT,RIGHT}
class _HomePageState extends State<HomePage> {
  // grid dimensions
  int rowSize = 10;
  int totalnumberofsquare = 100;
  bool gameHasStarted = false;
  final _nameController = TextEditingController();
  // user score
  int currentScore = 0;
  // snake position
  List<int> snakePos = [
    0,
    1,
    2,
  ];
  // snake direction is initially to right
  var currentDirection = Snake_Direction.RIGHT;
  // food position
  int foodPos = 55;
// high score list
  List<String> highscore_DocIds = [];
  late final Future ? letsGetDocIds;
  @override
  void initState(){
    letsGetDocIds = getDocId();
    super.initState();
  }
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
        highscore_DocIds.add(element.reference.id);
    }));

  }
  // Start the game!!
  void startGame(){
    gameHasStarted = true;
 Timer.periodic(Duration(milliseconds:200), (timer) {
   setState(() {
     // keep the snake moving
    moveSnake();

    // check if game is over
     if(gameOver()){
       timer.cancel();
       // DISPLAY a message to the user
       showDialog(context: context,
           barrierDismissible: false,
           builder: (context) {
             return  AlertDialog(
               title: Text('Game Over'),
               content: Column(
                 children: [
                   Text('your score is :' + currentScore.toString()),
                   TextField(
                     controller: _nameController,
                     decoration: InputDecoration(hintText: 'Enter Name'),
                   ),
                 ],
               ),
               actions: [MaterialButton(
                 onPressed: (){
                   Navigator.pop(context);
                   submitScore();
                   newGame();
                 },
                 child: Text('submit'),
                 color: Colors.pink,
               )
               ],
             );
           });
     }
   });
 });
  }
  void submitScore(){
    // get access to the collection
    var database = FirebaseFirestore.instance;
    database.collection('highscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }
  Future newGame() async{
    highscore_DocIds = [];
    await getDocId();
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = Snake_Direction.RIGHT;
      gameHasStarted = false;
      currentScore = 0;
    });
  }
  void eatfood(){
    currentScore++;
    // making sure the new food is not where the snake is
  while(snakePos.contains(foodPos)){
    foodPos = Random().nextInt(totalnumberofsquare);
  }
  }
  void moveSnake(){
   switch (currentDirection){
     case Snake_Direction.RIGHT:
     {
       // add a new head
     // if snake is at the right of wall, need to readjust
       if(snakePos.last % rowSize == 9){
         snakePos.add(snakePos.last +1-rowSize);
       }
       else{
         snakePos.add(snakePos.last+1);
       }
     }
       break;
     case Snake_Direction.LEFT:
     {
       // add a new head
       // if snake is at the left of wall, need to readjust
       if(snakePos.last % rowSize == 0){
         snakePos.add(snakePos.last -1+rowSize);
       }
       else {
         snakePos.add(snakePos.last - 1);
       }
     }
       break;
     case Snake_Direction.UP:
     {
       // add a new head
       // if snake is at the up of wall, need to readjust
       if(snakePos.last <rowSize){
         snakePos.add(snakePos.last -rowSize+ totalnumberofsquare);
       }
       else {
         snakePos.add(snakePos.last - rowSize);
       }
     }
       break;
     case Snake_Direction.DOWN:
     {
       // add a new head
       // if snake is at the up of wall, need to readjust
       if(snakePos.last + rowSize>totalnumberofsquare){
         snakePos.add(snakePos.last +rowSize - totalnumberofsquare);
       }
       else {
         snakePos.add(snakePos.last + rowSize);
       }
     }
       break;
     default:
   }
   // snake is eating food
   if(snakePos.last == foodPos){
     eatfood();
   }
   else{
     // remove the tail
     snakePos.removeAt(0);
   }
   // game over

  }
  bool gameOver() {
    // the game is over when the snake runs into itself
    // this occurs when there is a duplicate position in snakePos list
    List<int> bodySnake = snakePos.sublist(0,snakePos.length-1);
    if(bodySnake.contains(snakePos.last)){
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    // get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus:true,
        onKey : (event){
          if(event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != Snake_Direction.UP){
            currentDirection = Snake_Direction.DOWN;
          } else if(event.isKeyPressed(LogicalKeyboardKey.arrowUp)&&
              currentDirection != Snake_Direction.UP){
            currentDirection = Snake_Direction.UP;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != Snake_Direction.RIGHT){
            currentDirection = Snake_Direction.LEFT;
          }else if(event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != Snake_Direction.LEFT){
            currentDirection = Snake_Direction.RIGHT;
          }
        },
        child: SizedBox(
          width: screenWidth >428 ? 428 :screenWidth,
          child: Column(
            children: [
              // high score
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // use current score
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Current Score',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(currentScore.toString(),
                            style: TextStyle(fontSize: 36,color: Colors.white),
                          ),
                ],
                ),
                    ),
                        // highscore top 5 or 10
                        Expanded(
                          child: gameHasStarted
                            ?Container()
                          :FutureBuilder(
                            future: letsGetDocIds,
                              builder: (context,snapshot){
                                return ListView.builder(
                                    itemCount: highscore_DocIds.length,
                                    itemBuilder: ((context,index){
                                  return HighScoretitle(
                                      documentId: highscore_DocIds[index]);
                                }));
                              }),
                        )
                      ],
                    ),
              ),


              // game grid
              Expanded(
                flex: 3,

                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if(details.delta.dy>0 && currentDirection!= Snake_Direction.UP){
                      currentDirection = Snake_Direction.DOWN;
                    }
                     else if(details.delta.dy<0 && currentDirection!= Snake_Direction.DOWN){
                      currentDirection = Snake_Direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details){
                    if(details.delta.dx>0 && currentDirection!= Snake_Direction.LEFT){
                      currentDirection = Snake_Direction.RIGHT;
                    }
                    else if(details.delta.dx<0 && currentDirection!= Snake_Direction.RIGHT){
                      currentDirection = Snake_Direction.LEFT;
                    }
                  },

                  child: GridView.builder(
                      itemCount: totalnumberofsquare,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: rowSize  ),
                      itemBuilder: (context, index){
                        if(snakePos.contains(index)){
                          return const SnakePixel();
                        }
                        else if(foodPos== index){
                          return const FoodPixel();
                        }
                        else {
                          return const BlankPixel();
                        }
                      }
                  ),
                ),
              ),
              // play button
              Expanded(
                child: Container(
                  child: Center(
                  child: MaterialButton(
                    child: Text('PLAY'),
                    color: gameHasStarted ? Colors.grey: Colors.pink,
                    onPressed: gameHasStarted ? () {} : startGame,
                  ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
