import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/AppWidget.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'DashboardScreen.dart';
import 'WalkThroughScreen1.dart';
import 'WalkThroughScreen2.dart';
import 'WalkThroughScreen3.dart';
import '../model/MainResponse.dart' as model1;

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen2';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  List<model1.Walkthrough> mWalkList = [];

  late AnimationController _logoController;
  late Animation<Offset> _logoDropAnimation;

  String _fullText = "";
  String _visibleText = "";
  int _textIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();

    // Setup animation
    _logoController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _logoDropAnimation = Tween<Offset>(
      begin: const Offset(0, -10.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.linear,),
    );

    _logoController.forward();

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start typing effect after logo drops
        _fullText = getStringAsync(SPLASH_TITLE);
        _startTyping();
      }
    });

    init();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _visibleText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  init() async {
    Iterable mMenu = jsonDecode(getStringAsync(WALKTHROUGH));
    mWalkList =
        mMenu.map((model) => model1.Walkthrough.fromJson(model)).toList();

    await Future.delayed(const Duration(seconds: 3)); // wait for animation
    if (getStringAsync(IS_WALKTHROUGH) == "true") {
      if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
        if (mWalkList.isNotEmpty) {
          if (getStringAsync(WALK_THROUGH_STYLE) == WALK_THROUGH_1)
            return WalkThroughScreen1().launch(context, isNewTask: true);
          else if (getStringAsync(WALK_THROUGH_STYLE) == WALK_THROUGH_2)
            return WalkThroughScreen2().launch(context, isNewTask: true);
          else
            return WalkThroughScreen3().launch(context, isNewTask: true);
        } else {
          DashBoardScreen().launch(context, isNewTask: true);
        }
      } else {
        DashBoardScreen().launch(context, isNewTask: true);
      }
    } else {
      DashBoardScreen().launch(context, isNewTask: true);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _logoController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getStringAsync(SPLASH_ENABLE_BACKGROUND) == "true"
          ? Stack(
        alignment: Alignment.center,
        children: [
          cachedImage(getStringAsync(SPLASH_BACKGROUND_URL),
              fit: BoxFit.cover,
              height: context.height(),
              width: context.width()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getStringAsync(SPLASH_ENABLE_LOGO) != "false"
                  ? SlideTransition(
                position: _logoDropAnimation,
                child: cachedImage(
                  getStringAsync(SPLASH_LOGO_URL),
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                ).cornerRadiusWithClipRRect(10),
              )
                  : const SizedBox(),
              16.height,
              getStringAsync(SPLASH_ENABLE_TITLE) != "false"
                  ? Text(
                _visibleText,
                style: boldTextStyle(
                  size: 20,
                  color: getColorFromHex(
                    getStringAsync(SPLASH_TITLE_COLOR),
                    defaultColor: primaryColor1,
                  ),
                ),
                textAlign: TextAlign.center,
              ).paddingSymmetric(horizontal: 12)
                  : const SizedBox(),
            ],
          ).center(),
        ],
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              getColorFromHex(getStringAsync(SPLASH_FIRST_COLOR),
                  defaultColor: primaryColor1),
              getColorFromHex(getStringAsync(SPLASH_SECOND_COLOR),
                  defaultColor: primaryColor1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getStringAsync(SPLASH_ENABLE_LOGO) != "false"
                ? SlideTransition(
              position: _logoDropAnimation,
              child: cachedImage(
                getStringAsync(SPLASH_LOGO_URL),
                fit: BoxFit.cover,
                height: 120,
                width: 120,
              ).cornerRadiusWithClipRRect(10),
            )
                : const SizedBox(),
            16.height,
            getStringAsync(SPLASH_ENABLE_TITLE) != "false"
                ? Text(
              _visibleText,
              style: boldTextStyle(
                size: 20,
                color: getColorFromHex(
                  getStringAsync(SPLASH_TITLE_COLOR),
                  defaultColor: primaryColor1,
                ),
              ),
            )
                : const SizedBox(),
          ],
        ).center(),
      ),
    );
  }
}
