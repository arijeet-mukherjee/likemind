import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/AppConfig.dart';
import '../../config/SizeConfig.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/ThemeProvider.dart';
import '../../screens/Tabs.dart';
import '../../screens/auth/Login.dart';
import '../../screens/landing/Onboarding.dart';
import '../../utils/SessionManager.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SessionManager prefs = SessionManager();

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  _checkIfFirstTime() async {
    bool firsttime = await prefs.getFirstTime();
    if (firsttime) {
      await prefs.setFirstTime(false);
      _navigateToOnBoardScreen();
    } else {
      _checkIfLoggedIn();
    }
  }

  _checkIfLoggedIn() async {
    var loggedInUser = await prefs.getUser();
    if (loggedInUser != null) {
      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      await prefs.getUser().then((user) async {
        if (user.source == null) {
          prefs.getPassword().then((password) {
            if (password != null) {
              authProvider
                  .loginUser(context, user.email, password)
                  .then((user) async {
                if (user != null) _navigateToTabsScreen();
              });
            }
          });
        } else {
          await authProvider.setUser(user);
          _navigateToTabsScreen();
        }
      });
    } else {
      _navigateToLoginScreen();
    }
  }

  _navigateToOnBoardScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, OnBoardingScreen.routeName);
    });
  }

  _navigateToLoginScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
  }

  _navigateToTabsScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, TabsScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              theme.isDarkTheme()
                  ? 'assets/images/app_icon_dark.png'
                  : 'assets/images/app_icon.png',
              width: SizeConfig.blockSizeHorizontal * 35,
            ),
            /* Text(
              APP_NAME,
              style: TextStyle(
                fontFamily: 'Trueno',
                fontSize: SizeConfig.safeBlockHorizontal * 7,
                color: Theme.of(context).primaryColor,
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
