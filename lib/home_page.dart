import 'package:flutter/material.dart';
import 'package:flutter_stateless_chessboard/flutter_stateless_chessboard.dart';
import 'dart:math';
import 'utils.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    final padding = MediaQuery.of(context)
        .padding
        .top; // This accounts for the status bar height

    final availableHeight = size.height - appBarHeight - padding;
    final chessboardSize = min(size.width, availableHeight);

    return Scaffold(
      appBar: AppBar(
        title: Text("Random Chess"),
      ),
      body: Center(
        child: Chessboard(
          fen: _fen,
          size: chessboardSize,
          onMove: (move) {
            final nextFen = makeMove(_fen, {
              'from': move.from,
              'to': move.to,
              'promotion': 'q',
            });

            if (nextFen != "") {
              setState(() {
                _fen = nextFen;
              });

              Future.delayed(Duration(milliseconds: 300)).then((_) {
                final nextMove = getRandomMove(_fen);

                if (nextMove != "") {
                  setState(() {
                    _fen = makeMove(_fen, nextMove);
                  });
                }
              });
            }
          },
        ),
      ),
    );
  }
}
