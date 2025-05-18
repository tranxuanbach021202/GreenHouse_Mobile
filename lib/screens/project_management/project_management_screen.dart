import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/core/router/app_router.dart';
import 'package:greenhouse/di/di.dart';
import 'package:greenhouse/screens/project_management/viewmodel/project_management_view_model.dart';
import 'package:greenhouse/screens/project_management/widget/project_card.dart';
import 'package:greenhouse/screens/project_management/widget/project_skeleton.dart';
import 'package:provider/provider.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectManagementViewModel>.value(
      value: getIt<ProjectManagementViewModel>(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.bg_spash,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Quản lý dự án', style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      context.push('/general_info_project');
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Consumer<ProjectManagementViewModel>(
                builder: (context, viewModel, _) {
                  // Display loading skeletons when it's the initial loading
                  if (viewModel.isLoading) {
                    return ListView.builder(
                      itemCount: 4, // Show 4 skeleton items
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        return const ProjectSkeleton();
                      },
                    );
                  }

                  if (!viewModel.isLoading && viewModel.projects.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có dự án nào được tạo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent) {
                        viewModel.loadProjects();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: viewModel.projects.length + (viewModel.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < viewModel.projects.length) {
                          return ProjectCard(project: viewModel.projects[index]);
                        } else {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
