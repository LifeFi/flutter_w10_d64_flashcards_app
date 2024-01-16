import 'dart:math';

import 'package:flutter/material.dart';

Map<String, dynamic> contents = {
  "0": {
    "front": "문제 0",
    "back": "답 0",
  },
  "1": {
    "front": "문제 1",
    "back": "답 1",
  },
  "2": {
    "front": "문제 2",
    "back": "답 2",
  },
  "3": {
    "front": "문제 3",
    "back": "답 3",
  },
  "4": {
    "front": "문제 4",
    "back": "답 4",
  },
};

class D64FlashcardsApp extends StatefulWidget {
  const D64FlashcardsApp({super.key});

  @override
  State<D64FlashcardsApp> createState() => _D64FlashcardsAppState();
}

class _D64FlashcardsAppState extends State<D64FlashcardsApp>
    with TickerProviderStateMixin {
  late final size = MediaQuery.of(context).size;

  late final AnimationController _position = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    lowerBound: (size.width + 100) * -1,
    upperBound: (size.width + 100),
    value: 0.0,
  );

  late final Tween<double> _rotation = Tween(
    begin: -15,
    end: 15,
  );

  late final Tween<double> _scale = Tween(
    begin: 0.8,
    end: 1.0,
  );
  late final Tween<double> _opacity = Tween(
    begin: 0.0,
    end: 1.0,
  );

  int index = 0;
  bool _isFront = true;
  bool isVisibleCardChanged = false;
  double _rotateAnimBegin = 0.0;

  _onHorizontalDragUpdate(DragUpdateDetails detail) {
    _position.value += detail.delta.dx;
  }

  _onHorizontalDragEnd(DragEndDetails detail) {
    final bound = size.width - 200;

    if (_position.value.abs() >= bound) {
      _position
          .animateTo(
        _position.value.isNegative
            ? _position.lowerBound
            : _position.upperBound,
        curve: Curves.easeInOut,
      )
          .whenComplete(() {
        _position.value = 0.0;
        setState(
          () {
            index = index == contents.length - 1 ? 0 : index + 1;
            _isFront = true;
            // 뒤면인 상태에서, index 변경시, fron로 뒤집히는 animation 안보이게 하기 위한 편법.
            _rotateAnimBegin = 1.0;

            if (index == 0) {
              _progressController.value = ((index + 1) / contents.length);
            } else {
              _progressController.animateTo((index + 1) / contents.length,
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  curve: Curves.easeInOut);
            }
          },
        );
      });
    } else {
      _position.animateTo(
        0.0,
        curve: Curves.easeInOut,
      );
    }
  }

  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void dispose() {
    _position.dispose();
    _progressController.dispose();
    super.dispose();
  }

  _onToggleSide() {
    print(_isFront);
    setState(() {
      _rotateAnimBegin = 0.0;
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _position,
        builder: (context, child) {
          final angle = _rotation
                  .transform((_position.value / _position.upperBound + 1) / 2) *
              pi /
              180;
          final scale =
              _scale.transform(_position.value.abs() / _position.upperBound);
          final opacity =
              _opacity.transform(_position.value.abs() / _position.upperBound);

          final color = _position.value < 0
              ? Color.lerp(Colors.blue, Colors.orange,
                  min(1.0, _position.value.abs() / _position.upperBound * 7))
              : Color.lerp(Colors.blue, Colors.green,
                  min(1.0, _position.value.abs() / _position.upperBound * 7));

          // final color = _position.value < 0
          //     ? _reviewColor
          //         .transform((_position.value.abs() / _position.upperBound))
          //     : _reviewColor
          //         .transform((_position.value.abs() / _position.upperBound));
          // print("opacity: $opacity / _position.value: ${_position.value}");

          // print("${_position.value} / $angle");

          return Container(
            color: color,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: size.height * 0.2 - 70,
                  child: Opacity(
                    opacity: min(1.0, opacity * 7),
                    child: Text(
                      _position.value < 0 ? "Need to review" : "I got it right",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Cards(
                        index: index == contents.length - 1 ? 0 : index + 1,
                        isFront: true,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onTap: _onToggleSide,
                    child: Transform.rotate(
                      angle: angle,
                      child: Transform.translate(
                        offset: Offset(_position.value, 0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            final rotateAnim =
                                Tween(begin: _rotateAnimBegin, end: 1.0)
                                    .animate(animation);

                            return AnimatedBuilder(
                              animation: rotateAnim,
                              builder: (context, child) {
                                final flipAngle = rotateAnim.value < 0.5
                                    ? pi * rotateAnim.value
                                    : pi * (rotateAnim.value - 1);

                                // print("rotateAnim.value : ${rotateAnim.value}");
                                // print("flipAngle: $flipAngle");
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(flipAngle)
                                  // ..setRotationX(extraRotation)
                                  ,
                                  child: _isFront
                                      ? rotateAnim.value < 0.5
                                          ? Cards(
                                              key: const ValueKey(0),
                                              index: index,
                                              isFront: false,
                                            )
                                          : Cards(
                                              key: const ValueKey(1),
                                              index: index,
                                              isFront: true,
                                            )
                                      : rotateAnim.value < 0.5
                                          ? Cards(
                                              key: const ValueKey(0),
                                              index: index,
                                              isFront: true,
                                            )
                                          : Cards(
                                              key: const ValueKey(1),
                                              index: index,
                                              isFront: false,
                                            ),
                                );
                              },
                            );
                          },
                          child: _isFront
                              ? Cards(
                                  key: const ValueKey(0),
                                  index: index,
                                  isFront: true,
                                )
                              : Cards(
                                  key: const ValueKey(1),
                                  index: index,
                                  isFront: false,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 60,
                    width: size.width * 0.8 - 10,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) => CustomPaint(
                        size: const Size(
                          0,
                          0,
                        ),
                        painter: ProgressBarPainter(
                          progress: _progressController.value,
                        ),
                      ),
                    ))
              ],
            ),
          );
        },
      ),
    );
  }
}

class Cards extends StatelessWidget {
  final int index;
  final bool isFront;

  const Cards({
    super.key,
    required this.index,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.5,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        contents[index.toString()][isFront ? "front" : "back"],
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  late double progress;

  ProgressBarPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundBarPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);

    final backgroundBarPaint = Paint()
      ..strokeWidth = 10
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      backgroundBarPath,
      backgroundBarPaint,
    );

    final progressBarPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * progress, 0);

    final progressBarPaint = Paint()
      ..strokeWidth = 10
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      progressBarPath,
      progressBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) {
    // return oldDelegate.progress != progress;
    return true;
  }
}
