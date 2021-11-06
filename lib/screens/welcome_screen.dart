import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../widgets/wide_button.dart';
import '../constants.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    // animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
    animation = ColorTween(begin: AppTheme.darkBlue, end: AppTheme.almostWhite)
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      // appBar: AppBar(title: Text("Welcome Screen")),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('assets/images/icon.png'),
                    height: 60.0,
                  ),
                ),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.redBrown,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'The Pantry',
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 48.0),
            WideButton(
              color: AppTheme.blue,
              text: 'Login',
              onPressed: () => Navigator.pushNamed(context, LoginScreen.id),
            ),
            WideButton(
              color: AppTheme.darkBlue,
              text: 'Register',
              onPressed: () =>
                  Navigator.pushNamed(context, RegistrationScreen.id),
            ),
          ],
        ),
      ),
    );
  }
}
