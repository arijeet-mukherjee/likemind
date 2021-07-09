import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/auth/Login.dart';
import 'package:answer_me/screens/other/ConversationScreen.dart';
import 'package:answer_me/screens/other/EditProfile.dart';
import 'package:answer_me/screens/other/FollowingFollowers.dart';
import 'package:answer_me/screens/other/Information.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/SettingsListItem.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:universal_platform/universal_platform.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeProvider _themeProvider;

  _rateApp() {
    LaunchReview.launch(iOSAppId: IOS_APP_ID);
  }

  _shareApp() {
    try {
      if (UniversalPlatform.isAndroid) {
        Share.share('$SHARE_TEXT \n $ANDROID_SHARE_URL');
      } else if (UniversalPlatform.isIOS) {
        Share.share('$SHARE_TEXT \n $IOS_SHARE_URL');
      }
    } catch (e) {
      print(e);
    }
  }

  _logout(BuildContext context, AuthProvider auth) async {
    SessionManager pref = SessionManager();
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.routeName,
      (route) => false,
    );
    await pref.clearUser();
    await auth.clearUser();
    await Provider.of<ConversationProvider>(context, listen: false)
        .resetConversations();
  }

  _deleteAccount(BuildContext context, AuthProvider auth) async {
    showConfirmationDialog(
      context,
      text: 'Are you sure you want to delete your account?',
      yes: () async {
        await ApiRepository.deleteAccount(context, userId: auth.user.id)
            .then((value) {
          _logout(context, auth);
        });
      },
      no: () => Navigator.pop(context),
    );
  }

  _navigateToAuthorProfile(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null && auth.user.id != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => UserProfile(authorId: auth.user.id),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.black.withOpacity(0.2)),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  _appBar(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Settings', style: theme.isDarkTheme()?Theme.of(context).textTheme.headline6:TextStyle(
              fontFamily: 'Equinox',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: Colors.white,
            )),
      backgroundColor: theme.isDarkTheme()?ThemeData.dark().scaffoldBackgroundColor:kPrimaryColor,
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_6),
          color:
              Provider.of<ThemeProvider>(context, listen: false).isDarkTheme()
                  ? Colors.white
                  : Colors.white,
          onPressed: () {
            Provider.of<ThemeProvider>(context, listen: false).swapTheme();
          },
        )
      ],
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: SizeConfig.blockSizeVertical * 3),
                _buildUserImage(context),
                SizedBox(height: SizeConfig.blockSizeVertical),
                _buildUserName(context),
                /* SizedBox(height: SizeConfig.blockSizeVertical * 2),
                _buildFollowingFollowersRow(context), */
                SizedBox(height: SizeConfig.blockSizeVertical),
                _buildScreenButtonsList(context),
                _buildBottomScreenButtonsList(context),
                _buildLogoutAndDeleteList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildUserImage(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToAuthorProfile(context),
      child: Consumer<AuthProvider>(builder: (context, auth, child) {
        if (auth.user == null || auth.user.avatar == null) {
          return CircleAvatar(
            backgroundImage: AssetImage('assets/images/user_icon.png'),
            backgroundColor: Colors.transparent,
            maxRadius: SizeConfig.blockSizeHorizontal * 9.5,
          );
        } else {
          return CircleAvatar(
            backgroundImage: NetworkImage(
              auth.user.avatar,
            ),
            backgroundColor: Colors.transparent,
            maxRadius: SizeConfig.blockSizeHorizontal * 9.5,
          );
        }
      }),
    );
  }

  _buildUserName(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToAuthorProfile(context),
      child: Consumer<AuthProvider>(builder: (context, auth, child) {
        if (auth.user == null || auth.user.displayname == null) {
          return GestureDetector(
            onTap: () {
              AuthProvider authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginScreen.routeName, (route) => false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FluentIcons.person_20_filled,
                  size: SizeConfig.blockSizeHorizontal * 5,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal),
                Text(
                  'Login',
                  style: GoogleFonts.lato(
                    fontSize: SizeConfig.safeBlockHorizontal * 4.2,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text(
            auth.user.displayname,
            style: GoogleFonts.lato(
              fontSize: SizeConfig.safeBlockHorizontal * 5,
            ),
          );
        }
      }),
    );
  }

  _buildFollowingFollowersRow(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.user != null && auth.user.id != null) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFollowCount(
                context,
                text: 'Following',
                count: auth.user.following ?? 0,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => FollowingFollowersScreen(
                      authorId: auth.user.id,
                      index: 1,
                    ),
                  ),
                ),
              ),
              _buildFollowCount(
                context,
                text: 'Followers',
                count: auth.user.followers ?? 0,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => FollowingFollowersScreen(
                      authorId: auth.user.id,
                      index: 1,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  _buildFollowCount(BuildContext context,
      {String text, int count, Function onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.6),
              Text(
                text,
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  _buildScreenButtonsList(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => _buttonsListContainer(
        context,
        Column(
          children: [
            auth.user == null || auth.user.username == null
                ? Container()
                : SettingsListItem(
                    text: 'Edit Profile',
                    arrow: true,
                    first: true,
                    onTap: () => Navigator.pushNamed(
                        context, EditProfileScreen.routeName),
                  ),
            auth.user == null || auth.user.username == null
                ? Container()
                : SettingsListItem(
                    text: 'My Profile',
                    arrow: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => UserProfile(authorId:auth.user.id)),
                    ),
                  ),
            SettingsListItem(
              text: 'Points',
              arrow: true,
              first: auth.user != null && auth.user.id != null ? false : true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => InformationScreen(title: 'Points'),
                ),
              ),
            ),
            SettingsListItem(
              text: 'Share the app',
              arrow: false,
              onTap: () => _shareApp(),
            ),
            SettingsListItem(
              text: 'Rate this app',
              arrow: false,
              onTap: () => _rateApp(),
            ),
          ],
        ),
      ),
    );
  }

  _buildBottomScreenButtonsList(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => Container(
        child: _buttonsListContainer(
          context,
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SettingsListItem(
                text: 'About Us',
                arrow: true,
                first: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => InformationScreen(title: 'About Us'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'Contact Us',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => InformationScreen(title: 'Contact Us'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'FAQ',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => InformationScreen(title: 'FAQ'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'Privacy Policy',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        InformationScreen(title: 'Privacy Policy'),
                  ),
                ),
              ),
              SettingsListItem(
                text: 'Terms and Conditions',
                arrow: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        InformationScreen(title: 'Terms and Conditions'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildLogoutAndDeleteList(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.user != null && auth.user.username != null) {
          return Container(
            padding: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
            child: _buttonsListContainer(
              context,
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  auth.user == null || auth.user.username == null
                      ? Container()
                      : SettingsListItem(
                          text: 'Logout',
                          arrow: true,
                          first: true,
                          color: Theme.of(context).primaryColor,
                          onTap: () => _logout(context, auth),
                        ),
                  auth.user == null || auth.user.username == null
                      ? Container()
                      : SettingsListItem(
                          text: 'Delete Account',
                          arrow: false,
                          color: Colors.red,
                          onTap: () => _deleteAccount(context, auth),
                        ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  _buttonsListContainer(BuildContext context, Widget body) {
    return Container(
      margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
      decoration: BoxDecoration(
        border: Border.all(
            color:
                _themeProvider.isDarkTheme() ? Colors.black12 : Colors.white10,
            width: 1.0),
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _themeProvider.isDarkTheme()
                ? Colors.black12
                : Color(0xFFCFDCE7),
            blurRadius: 3.0,
            offset: Offset(0.2, 0.2),
          ),
        ],
      ),
      child: body,
    );
  }
}
