import 'package:flutter/material.dart';

class IntroPageThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/img3.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment(0.0, -0.35),
                child: Text(
                  'Collect master pieces',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              
            ],
          ),
          Row(
            children: [
              Align(
                alignment: Alignment(0.0, -0.2),
                child: Text(
                  'Powered by Latent Diffusion Model',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}