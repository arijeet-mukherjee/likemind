import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/screens/auth/Login.dart';
import 'package:flutter/material.dart';
import 'package:minimal_onboarding/minimal_onboarding.dart';

class OnBoardingScreen extends StatelessWidget {
  static const routeName = 'onboarding_screen';

  final onboardingPages = [
    OnboardingPageModel(
      'assets/images/onboarding_1.jpg',
      'Welcome',
      '$APP_NAME is a stunning profressional and flexible social question and answer app',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_2.jpg',
      'You are here',
      'Specialy designed for Online Communities, Niche Questions.',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_3.jpg',
      'Continue to LikeMind',
      'Marketing Websites, Developers Websites, or any kind of Social Communities',
    ),
  ];

  _navigateToLoginScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MinimalOnboarding(
        onboardingPages: onboardingPages,
        color: Theme.of(context).primaryColor,
        dotsDecoration: DotsDecorator(
          activeColor: Theme.of(context).primaryColor,
          size: Size.square(9.0),
          activeSize: Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onFinishButtonPressed: () => _navigateToLoginScreen(context),
        onSkipButtonPressed: () => _navigateToLoginScreen(context),
      ),
    );
  }
}
