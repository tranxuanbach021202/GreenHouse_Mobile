
import 'package:flutter/material.dart';
import 'package:greenhouse/base/services/websocket_serivce.dart';
import 'package:greenhouse/utils/logger.dart';
import 'package:lottie/lottie.dart';

import '../base/services/storage_service.dart';
import '../di/di.dart';
import 'nav_bar.dart';
import 'nav_model.dart';

class MainScreenA extends StatefulWidget {
  const MainScreenA({super.key});

  @override
  State<MainScreenA> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenA> {
  final homeNavKey = GlobalKey<NavigatorState>();
  final searchNavKey = GlobalKey<NavigatorState>();
  final notificationNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  int selectedTab = 0;
  List<NavModel> items = [];

  WebSocketService? socketService;

  @override
  void initState() {
    super.initState();


    // final storageService = getIt<StorageService>();
    // final userId = storageService.getCurrentUserId();
    //
    // if (userId != null) {
    //   logger.i("userId: $userId");
    //   socketService = WebSocketService(userId);
    //   socketService!.connect();
    // }


    items = [
      NavModel(
        page: const TabPage(tab: 1),
        navKey: homeNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 2),
        navKey: searchNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 3),
        navKey: notificationNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 4),
        navKey: profileNavKey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (items[selectedTab].navKey.currentState?.canPop() ?? false) {
          items[selectedTab].navKey.currentState?.pop();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedTab,
          children: items
              .map((page) => Navigator(
            key: page.navKey,
            onGenerateInitialRoutes: (navigator, initialRoute) {
              return [
                MaterialPageRoute(builder: (context) => page.page)
              ];
            },
          ))
              .toList(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(top: 20),
          height: 64,
          width: 64,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            elevation: 0,
            onPressed: () => debugPrint("Add Button pressed"),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 3, color: Colors.green),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Transform.scale(
              scale: 2,
              child: Lottie.asset(
                'assets/animations/scan_qr.json',
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),

          ),
        ),
        bottomNavigationBar: NavBar(
          pageIndex: selectedTab,
          onTap: (index) {
            if (index == selectedTab) {
              items[index]
                  .navKey
                  .currentState
                  ?.popUntil((route) => route.isFirst);
            } else {
              setState(() {
                selectedTab = index;
              });
            }
          },
        ),
      ),
    );
  }


  @override
  void dispose() {
    socketService?.disconnect();
    super.dispose();
  }
}

class TabPage extends StatelessWidget {
  final int tab;

  const TabPage({Key? key, required this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tab $tab')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tab $tab'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Page(tab: tab),
                  ),
                );
              },
              child: const Text('Go to page'),
            )
          ],
        ),
      ),
    );
  }


}

class Page extends StatelessWidget {
  final int tab;

  const Page({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page Tab $tab')),
      body: Center(child: Text('Tab $tab')),
    );
  }
}