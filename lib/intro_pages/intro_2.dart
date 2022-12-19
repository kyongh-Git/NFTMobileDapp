import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IntroPageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/img4.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment(-0.5, -0.8),
                child: SizedBox(
                  width: 250.0,
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontFamily: 'Canterbury',
                    ),
                    
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText('Create your own art piece,'),
                        TyperAnimatedText('and mint it to Blockchain,'),
                        TyperAnimatedText('Enjoy Decentralized World!'),
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}