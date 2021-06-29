import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Point.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class InformationScreen extends StatefulWidget {
  static const routeName = "information_screen";

  final String title;

  const InformationScreen({Key key, this.title}) : super(key: key);

  @override
  _InformationScreenState createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _messageController = TextEditingController();

  List<Point> _points = [];
  // List<Badge> _badges = [];

  bool _isLoading = true;

  _sendMessage() async {
    if (_formKey.currentState.validate()) {
      await ApiRepository.sendMessage(
        context,
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      ).then((value) => _clearFields());
    }
  }

  _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == 'Points') {
      _getPoints();
      // _getBadges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      leading: AppBarLeadingButton(),
      title: Text(widget.title, style: Theme.of(context).textTheme.headline6),
      centerTitle: true,
    );
  }

  _body(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);
    switch (widget.title) {
      case 'About Us':
        return _buildHtmlContent(
          body: _buildHtmlBody(content: appProvider.settings.aboutUs),
        );
        break;
      case 'Privacy Policy':
        return _buildHtmlContent(
            body: _buildHtmlBody(content: appProvider.settings.privacyPolicy));
        break;
      case 'FAQ':
        return _buildHtmlContent(
            body: _buildHtmlBody(content: appProvider.settings.faq));
        break;
      case 'Terms and Conditions':
        return _buildHtmlContent(
            body: _buildHtmlBody(
          content: appProvider.settings.termsAndConditions,
        ));
        break;
      case 'Points':
        return _buildBadgesAndPointsLayout();
        break;
      case 'Contact Us':
        return _buildContactUsContent(context,
            content: appProvider.settings.contactUs);
        break;
    }
  }

  _getPoints() async {
    await ApiRepository.getPoints(context).then((points) {
      setState(() {
        _points = points;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  // _getBadges() async {
  //   await ApiRepository.getBadges(context).then((badges) {
  //     setState(() {
  //       _badges = badges;
  //     });
  //   });

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  _buildHtmlContent({Widget body}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
        ),
        child: body,
      ),
    );
  }

  _buildHtmlBody({String content, Map<String, Style> style}) {
    return Html(
      data: content,
      style: style != null ? style : null,
    );
  }

  _buildContactUsContent(BuildContext context, {String content}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: SizeConfig.blockSizeVertical * 2,
            color: Theme.of(context).dividerColor,
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHtmlBody(
                    content: content,
                    style: {
                      'h2': Style(fontWeight: FontWeight.w500),
                      'p': Style(
                        color: Colors.black54,
                        fontSize: FontSize.large,
                        lineHeight: 1.6,
                      )
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        CustomTextField(
                          hint: 'Name',
                          controller: _nameController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        CustomTextField(
                          hint: 'Email',
                          controller: _emailController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        CustomTextField(
                          hint: 'Your Message',
                          maxLines: 4,
                          controller: _messageController,
                        ),
                        SizedBox(height: SizeConfig.blockSizeVertical * 4),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 25,
                          height: SizeConfig.blockSizeVertical * 6.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: Theme.of(context).primaryColor,
                            ),
                            onPressed: () => _sendMessage(),
                            child: Text(
                              'Send',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.safeBlockHorizontal * 4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildBadgesAndPointsLayout() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.blockSizeVertical * 3),
                  Text(
                    'Points',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: SizeConfig.safeBlockHorizontal * 9,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical),
                  Text(
                    'Besides gaining reputation with your questions and answers, you receive points for being especially helpful. Points appears on your profile page, questions & answers.',
                    style: GoogleFonts.lato(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                      height: SizeConfig.blockSizeVertical * 0.2,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 5),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: SizeConfig.blockSizeHorizontal * 2,
                          ),
                          child: Text(
                            'Action',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.lato(
                              fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Points',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _points.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, i) => _pointListItem(
                      _points[i],
                      last: i == _points.length - 1 ? true : false,
                    ),
                  ),
                  // SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  // Text(
                  //   'Badges',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: SizeConfig.safeBlockHorizontal * 9,
                  //   ),
                  // ),
                  // SizedBox(height: SizeConfig.blockSizeVertical),
                  // Text(
                  //   'Besides gaining reputation with your questions and answers, you receive badges for being especially helpful. Badges appears on your profile page, questions & answers.',
                  //   style: TextStyle(
                  //     fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                  //     height: SizeConfig.blockSizeVertical * 0.2,
                  //   ),
                  // ),
                  // SizedBox(height: SizeConfig.blockSizeVertical * 2),
                  // ListView.builder(
                  //     shrinkWrap: true,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     itemCount: _badges.length,
                  //     itemBuilder: (ctx, i) => _badgeListItem(_badges[i])),
                  // SizedBox(height: SizeConfig.blockSizeVertical * 2),
                ],
              ),
            ),
          );
  }

  _pointListItem(Point point, {bool last = false}) {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(width: 1, color: Colors.grey.shade200),
      // ),
      // margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: SizeConfig.blockSizeHorizontal * 1.5,
                    right: SizeConfig.blockSizeHorizontal,
                  ),
                  child: Text(
                    point.description,
                    style: GoogleFonts.lato(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  point.points.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          !last ? Divider() : Container(),
        ],
      ),
    );
  }
}
