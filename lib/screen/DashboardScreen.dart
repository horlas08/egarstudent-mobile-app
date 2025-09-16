import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../component/BottomNavigationComponent1.dart';
import '../component/BottomNavigationComponent2.dart';
import '../component/BottomNavigationComponent3.dart';
import '../main.dart';
import '../model/MainResponse.dart';
import '../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../utils/common.dart';
import 'HomeScreen.dart';
import 'WebScreen.dart';
import 'package:flutter/services.dart';
import 'package:advanced_in_app_review/advanced_in_app_review.dart';

class DashBoardScreen extends StatefulWidget {
  static String tag = '/DashBoardScreen';

  final String? url;

  DashBoardScreen({this.url});

  @override
  DashBoardScreenState createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  List<MenuStyleModel> mBottomMenuList = [];
  List<Widget> widgets = [];
  String _platformVersion = 'Unknown';
  @override
  void initState() {
    super.initState();

    init();
    initPlatformState();
    AdvancedInAppReview()
        .setMinDaysBeforeRemind(7)
        .setMinDaysAfterInstall(2)
        .setMinLaunchTimes(2)
        .setMinSecondsBeforeShowDialog(4)
        .monitor();
  }

  init() async {
    setStatusBarColor(appStore.primaryColors,
        statusBarBrightness: Brightness.light);

    if (isMobile) {
      OneSignal.Notifications.addClickListener((event) {
        print("Notification URL" + event.notification.launchUrl.validate());
        if (!event.notification.launchUrl.isEmptyOrNull) {
          WebScreen(
            mInitialUrl: event.notification.launchUrl.validate(),
            mHeading: "",
          ).launch(context);
        }
      });
    }

    if (getStringAsync(NAVIGATIONSTYLE) ==
        NAVIGATION_STYLE_BOTTOM_NAVIGATION_SIDE_DRAWER) {
      Iterable mBottom = jsonDecode(getStringAsync(MENU_STYLE));
      mBottomMenuList =
          mBottom.map((model) => MenuStyleModel.fromJson(model)).toList();

      if (mBottomMenuList.isNotEmpty) {
        for (int i = 0; i < mBottomMenuList.length; i++) {
          widgets.add(HomeScreen(mUrl: mBottomMenuList[i].url));
        }
      } else {
        widgets.add(HomeScreen());
      }
    } else {
      Iterable mBottom = jsonDecode(getStringAsync(BOTTOMMENU));
      mBottomMenuList =
          mBottom.map((model) => MenuStyleModel.fromJson(model)).toList();
      if (getStringAsync(NAVIGATIONSTYLE) ==
              NAVIGATION_STYLE_BOTTOM_NAVIGATION &&
          mBottomMenuList.isNotEmpty) {
        for (int i = 0; i < appStore.mBottomNavigationList.length; i++) {
          widgets.add(HomeScreen(mUrl: mBottomMenuList[i].url));
        }
      } else {
        widgets.add(HomeScreen());
      }
    }

    log(appStore.currentIndex);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget mBottomStyle() {
    if (getStringAsync(NAVIGATIONSTYLE) ==
        NAVIGATION_STYLE_BOTTOM_NAVIGATION_SIDE_DRAWER) {
      if (getStringAsync(BOTTOM_NAVIGATION_STYLE) == BOTTOM_NAVIGATION_1)
        return BottomNavigationComponent3();
      else if (getStringAsync(BOTTOM_NAVIGATION_STYLE) == BOTTOM_NAVIGATION2)
        return BottomNavigationComponent2();
      else
        return BottomNavigationComponent1();
    } else {
      if (getStringAsync(BOTTOM_NAVIGATION_STYLE) == BOTTOM_NAVIGATION_1)
        return BottomNavigationComponent3();
      else if (getStringAsync(BOTTOM_NAVIGATION_STYLE) == BOTTOM_NAVIGATION2)
        return BottomNavigationComponent2();
      else
        return BottomNavigationComponent1();
    }
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await AdvancedInAppReview.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
  @override
  Widget build(BuildContext context) {

    return getStringAsync(NAVIGATIONSTYLE) ==
                NAVIGATION_STYLE_BOTTOM_NAVIGATION_SIDE_DRAWER ||
            getStringAsync(NAVIGATIONSTYLE) ==
                    NAVIGATION_STYLE_BOTTOM_NAVIGATION &&
                mBottomMenuList.isNotEmpty
        ? Scaffold(
            backgroundColor: context.scaffoldBackgroundColor,
            bottomNavigationBar: getStringAsync(ADD_TYPE) != NONE
                ? Container(
              color: Color(0xFFD9D9D9),
                    height: getStringAsync(BOTTOM_NAVIGATION_STYLE) ==
                                BOTTOM_NAVIGATION_1 ||
                            (getStringAsync(BOTTOM_NAVIGATION_STYLE) ==
                                BOTTOM_NAVIGATION2)
                        ? kToolbarHeight
                        : kToolbarHeight + 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // showBannerAds(),
                        Align(
                          alignment: Alignment.center,
                          child: mBottomStyle(),
                        ),
                      ],
                    ),
                  )
                : mBottomStyle(),
            body: Observer(
              builder: (_) => widgets[appStore.currentIndex],
            ),
          )
        : HomeScreen();
  }
}
