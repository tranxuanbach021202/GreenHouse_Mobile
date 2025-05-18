import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:greenhouse/base/services/storage_service.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:greenhouse/models/response/project_response.dart';
import 'package:greenhouse/screens/project_detail/data_entry_tab.dart';
import 'package:greenhouse/screens/project_detail/overview_tab.dart';
import 'package:greenhouse/screens/project_detail/experiment_layout_tab.dart';
import 'package:greenhouse/screens/project_detail/viewmodel/project_detail_view_model.dart';
import 'package:provider/provider.dart';
import '../../base/views/widget/appbar_leading_iconbutton.dart';
import '../../di/di.dart';
import '../../models/response/project_member_response.dart';
import '../../respositories/measurement_repository.dart';
import '../../respositories/project_repository.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  ProjectDetailState createState() => ProjectDetailState();
}

class ProjectDetailState extends State<ProjectDetailScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectDetailViewModel(
        projectId: widget.projectId,
        projectRepository: getIt<ProjectRepository>(),
        measurementRepository: getIt<MeasurementRepository>(),
        storageService: getIt<StorageService>(),
      ),
      child: Scaffold(
        backgroundColor: AppColors.backColor,
        // Thêm dòng này để cho phép nội dung tràn lên status bar
        extendBodyBehindAppBar: true,
        body: Consumer<ProjectDetailViewModel>(
          builder: (context, viewModel, _) {
            _tabController.addListener(() {
              if (_tabController.indexIsChanging) {
                context.read<ProjectDetailViewModel>().setTab(_tabController.index);
              }
            });
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            }

            if (viewModel.errorMessage != null) {
              return _buildErrorState(context, viewModel);
            }

            final project = viewModel.project;
            if (project == null) {
              return const Center(
                child: Text(
                  "Không có dữ liệu dự án.",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return _buildMainContent(context, project, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ProjectDetailViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.reload(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ProjectResponse project, ProjectDetailViewModel viewModel) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildProjectHeader(context, project, viewModel),
              const SizedBox(height: 16),
              _buildTabBar(context),
              const SizedBox(height: 8),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              OverviewTab(project: project),
              ExperimentLayoutTab(project: project),
              DataEntryTab(
                project: project,
                measurements: viewModel.measurementList,
              ),
            ],
          ),
        ),
      ],
    );
  }




  Widget _buildProjectHeader(BuildContext context, ProjectResponse project, ProjectDetailViewModel viewModel) {
    // Lấy chiều cao của status bar
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      // Tăng chiều cao của header để bao gồm cả status bar
      height: 220 + statusBarHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with overlay
          _buildHeaderBackground(project),

          // Content - thêm padding top bằng với chiều cao của status bar
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AppBar
                _buildCustomAppBar(context, project, viewModel),
                const SizedBox(height: 40),

                // Project title and visibility
                _buildProjectTitle(project),
                const SizedBox(height: 12),

                // Project creator info and members
                _buildProjectCreatorAndMembers(project),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeaderBackground(ProjectResponse project) {
    final hasThumbnail = project.thumbnailUrl != null &&
                     project.thumbnailUrl.isNotEmpty &&
                     project.thumbnailUrl.startsWith('http');

    return Stack(
      fit: StackFit.expand,
      children: [
        // Display project image from URL if available, otherwise use default image
        hasThumbnail
          ? Image.network(
              project.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to default image if network image fails to load
                return Image.asset(
                  AppImages.imageProject,
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                // Show default image while loading
                return Image.asset(
                  AppImages.imageProject,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              AppImages.imageProject,
              fit: BoxFit.cover,
            ),

        // Gradient overlay remains unchanged
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(BuildContext context, ProjectResponse project, ProjectDetailViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          AppbarLeadingIconButton(
            imagePath: AppImages.backIcon,
            height: 30,
            width: 30,
            onTap: () => Navigator.pop(context),
          ),

          const Spacer(),
          // Project code as title
          Text(
            project.code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),
          // Settings menu
          _buildSettingsMenu(context, project, viewModel),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context, ProjectResponse project, ProjectDetailViewModel viewModel) {
    return Container(
      alignment: Alignment.bottomRight,
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.settings,
          color: Colors.green,
          size: 28,
        ),
        onSelected: (value) async {
          if (value == 'public') {
            final isPublic = viewModel.project?.isPublic ?? false;
            final confirm = await _showConfirmationDialog(
              context,
              isPublic ? 'Tắt công khai dự án?' : 'Công khai dự án?',
              isPublic
                  ? 'Bạn có chắc muốn tắt chế độ công khai cho dự án này không?'
                  : 'Bạn có chắc muốn công khai dự án này không?',
            );

            if (confirm == true) {
              await viewModel.updateProjectPublicStatus(
                context,
                project.id,
                !isPublic,
              );
            }
          } else if (value == 'qr') {
            await viewModel.generateAndSaveQrPdf(
              context,
              project.id,
              'https://your-app-url.com',
              project.code,
            );
          } else if(value == 'export_data') {
            await viewModel.exportMeasurementToExcel(context, project.id);
          } else if (value == 'delete-project') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Xác nhận xoá'),
                content: const Text('Bạn có chắc chắn muốn xoá dự án này? Hành động này không thể hoàn tác.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Huỷ'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Xoá',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await viewModel.deleteProject(project.id, context);
            }
          }

        },
        itemBuilder: (BuildContext context) {
          final isPublic = viewModel.project?.isPublic ?? false;
          return [
            if (viewModel.isOwner)
              PopupMenuItem<String>(
                value: 'public',
                child: Row(
                  children: [
                    Icon(
                      isPublic ? Icons.visibility_off : Icons.visibility,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(isPublic ? 'Tắt công khai' : 'Công khai dự án'),
                  ],
                ),
              ),
            PopupMenuItem<String>(
              value: 'qr',
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Tạo mã QR layout'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'export_data',
              child: Row(
                children: [
                  Icon(
                    Icons.save,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Xuất data'),
                ],
              ),
            ),
            if (viewModel.isOwner)
              PopupMenuItem<String>(
                value: 'delete-project',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('Xoá dự án'),
                  ],
                ),
              ),
          ];
        },
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTitle(ProjectResponse project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Thêm padding 20 vào cả hai bên
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Project name
          Expanded(
            child: Text(
              project.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: project.isPublic ? Colors.green : Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              project.isPublic ? "Public" : "Group",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProjectCreatorAndMembers(ProjectResponse project) {
    final ownerMember = project.members.firstWhere(
          (member) => member.role.toUpperCase() == 'OWNER',
      orElse: () => project.members.isNotEmpty ? project.members.first : ProjectMemberResponse(
        userId: '',
        userName: '',
        email: '',
        displayName: '',
        urlAvatar: '',
        role: '',
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // Thêm padding 20 vào cả hai bên
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Created by info
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white),
              children: [
                TextSpan(
                  text: "Tạo bởi: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                TextSpan(
                  text: ownerMember.userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Member avatars
          _buildMemberAvatars(project),
        ],
      ),
    );
  }


  Widget _buildMemberAvatars(ProjectResponse project) {
    if (project.members.isEmpty) {
      return const SizedBox();
    }

    // Find owner
    final ownerMember = project.members.firstWhere(
      (member) => member.role.toUpperCase() == 'OWNER',
      orElse: () => project.members.first,
    );

    // Calculate additional members count (excluding owner)
    final additionalMembersCount = project.members.length - 1;

    return SizedBox(
      height: 24,
      width: 80,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Owner avatar
          _buildAvatarCircle(
            ownerMember.urlAvatar.isNotEmpty
                ? ownerMember.urlAvatar
                : AppImages.defaultAvatar
          ),

          // If there are additional members, show count circle
          if (additionalMembersCount > 0)
            Positioned(
              right: 0,
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  "+$additionalMembersCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(String imagePath) {
    return Container(
      height: 24,
      width: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imagePath.startsWith('http')
          ? Image.network(
              imagePath,
              height: 24,
              width: 24,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  AppImages.defaultAvatar,
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                );
              },
            )
          : Image.asset(
              imagePath,
              height: 24,
              width: 24,
              fit: BoxFit.cover,
            ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.green,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        indicatorPadding: const EdgeInsets.all(4.0),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        tabs: const [
          Tab(
            height: 40,
            text: "Chi tiết",
          ),
          Tab(
            height: 40,
            text: "Bố trí",
          ),
          Tab(
            height: 40,
            text: "Các đợt nhập",
          ),
        ],
      ),
    );
  }
}
