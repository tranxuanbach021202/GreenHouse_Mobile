import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/dashboard/dashboard_screen.dart';
import 'package:greenhouse/screens/home_screen/home_screen.dart';
import 'package:greenhouse/screens/invitations/invitation_screen.dart';
import 'package:greenhouse/screens/profile%20/profile_screen.dart';
import 'package:greenhouse/screens/project_creation/screen/general_info_screen.dart';
import 'package:greenhouse/screens/project_management/project_management_screen.dart';
import 'package:lottie/lottie.dart';

import '../base/services/storage_service.dart';
import '../base/services/websocket_serivce.dart';
import '../di/di.dart';
import '../utils/logger.dart';
import '../utils/nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  WebSocketService? socketService;
  int _pageIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    //
    // final storageService = getIt<StorageService>();
    // final userId = storageService.getCurrentUserId();
    //
    // if (userId != null) {
    //   logger.i("userId: $userId");
    //   socketService = WebSocketService(userId);
    //   socketService!.connect();
    // }


  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen();
      case 1:
        return ProjectManagementScreen();
      case 2:
        return InvitationScreen();
      case 3:
        return ProfileScreen();
      default:
        return DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildScreen(_pageIndex), // <- thay vì _screens[_pageIndex]
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 64,
            width: 64,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 0,
              onPressed: () async {
                final result = await context.push<String>('/scan_qr');
                if (result != null) {
                  setState(() {
                  });
                }
              },
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
        ],
      ),
      bottomNavigationBar: NavBar(
        pageIndex: _pageIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}




