// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:transfer/presentaion/GetStarted/getstarted.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tAnimation;
  late Animation<Offset> _tPositionAnimation;
  late Animation<Color?> _tColorAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // T animation - scales up and fades in
    _tAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // T position animation - slides to the left
    _tPositionAnimation = Tween<Offset>(
      begin: const Offset(0.6, 0),
      end: const Offset(0.2, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    // T color animation - changes from black to white
    _tColorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Rest of the text animation - fades in

    // Text opacity animation
    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    // Text offset animation
    _textOffsetAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1100), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GetStartedPage()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildT() {
    return AnimatedBuilder(
      animation: _tColorAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Outline
            Text(
              'T',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..color = Colors.black,
                letterSpacing: 2,
              ),
            ),
            // Fill
            Text(
              'T',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: _tColorAnimation.value,
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const GetStartedPage(),
        '/login': (context) =>  Container(), // Replace with your login page
      },
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/lock.json',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                repeat: false,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: _tPositionAnimation,
                    child: FadeTransition(
                      opacity: _tAnimation,
                      child: ScaleTransition(
                        scale: _tAnimation,
                        child: _buildT(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedBuilder(
                    animation: _textOffsetAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: Transform.translate(
                          offset: Offset(_textOffsetAnimation.value, 0),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'ransfer',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _textOpacityAnimation,
                child: const Text(
                  'Secure messaging made simple',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    letterSpacing: 1,
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

