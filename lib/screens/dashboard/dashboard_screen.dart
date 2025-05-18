import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/screens/dashboard/project_short_model.dart';
import 'package:greenhouse/screens/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:greenhouse/screens/dashboard/widget/analytics_card.dart';
import 'package:greenhouse/screens/dashboard/widget/app_bar_screen.dart';
import 'package:greenhouse/screens/dashboard/widget/project_card.dart';
import 'package:greenhouse/screens/dashboard/widget/search_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../search/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSearchOverlay = false;

  void _onProjectSelected(ProjectShort project) {
    print('Selected: ${project.projectName}');
    setState(() {
      _showSearchOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.bg_spash),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.2)),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: _buildBody(context, viewModel),
            ),
            if (_showSearchOverlay)
              SearchScreen(
                onClose: () => setState(() => _showSearchOverlay = false),
                onProjectSelected: _onProjectSelected,
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.isInitialized) {
      return Center(
        child: Lottie.asset(
          AppImages.loadding,
          width: 160,
          height: 160,
        ),
      );
    }
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBarScreen(),
            SearchBarScreen(
              onSelect: _onProjectSelected,
              onTap: () => setState(() => _showSearchOverlay = true),
            ),
            AnalyticsCard(),
            if (viewModel.myProjects.isNotEmpty)
              _MyProjectsList(projects: viewModel.myProjects),
            if (viewModel.publicProjects.isNotEmpty)
              _ProjectPublicList(projects: viewModel.publicProjects),
          ],
        ),
      ),
    );
  }
}

class _ProjectPublicList extends StatelessWidget {
  final List<ProjectShort> projects;

  const _ProjectPublicList({Key? key, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dự án công khai',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCard(
                project: projects[index],
                isDetailCard: false,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyProjectsList extends StatelessWidget {
  final List<ProjectShort> projects;

  const _MyProjectsList({Key? key, required this.projects}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dự án tham gia',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return ProjectCard(
                project: projects[index],
                isDetailCard: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
