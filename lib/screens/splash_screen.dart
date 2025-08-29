import 'package:flutter/material.dart';
import 'package:giglyric_latest/screens/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  late final animation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(animationController);

  void navigator() async {
    await Future.delayed(const Duration(seconds: 4), (){});

    if(!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage(),), (route) => false);
  }

  @override
  void initState() {
    // TODO: implement initState
    animationController.forward();
    navigator();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/splash_logo.png'),
            ],
          ),
        ),
      ),
    );
  }
}