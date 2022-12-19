import 'package:flutter/material.dart';

class IntroPageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Image.asset('assets/images/img1.jpg',
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,),
      ),
    );
  }
}

// Image.asset('assets/images/lake.jpg'), Text('Page 1')