import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:greenhouse/di/di.dart';
import 'package:greenhouse/respositories/project_repository.dart';
import 'package:greenhouse/screens/dashboard/widget/project_search_overlay.dart';
import 'package:provider/provider.dart';

import '../../search/search_screen.dart';
import '../project_short_model.dart';
import '../viewmodel/dashboard_view_model.dart';

class SearchBarScreen extends StatefulWidget {
  final void Function(ProjectShort project)? onSelect;
  final VoidCallback? onTap;

  const SearchBarScreen({Key? key, this.onSelect, this.onTap}) : super(key: key);

  @override
  State<SearchBarScreen> createState() => _SearchBarScreenState();
}


class _SearchBarScreenState extends State<SearchBarScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: widget.onTap, // 👈 gọi callback thay vì push
        child: Hero(
          tag: 'searchBar',
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Tên dự án',
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  Icon(Icons.tune, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _createSearchRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}


