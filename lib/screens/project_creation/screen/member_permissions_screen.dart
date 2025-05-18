import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/models/project_member.dart';
import 'package:greenhouse/screens/project_creation/widget/custom_dropdown_widget.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/core/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../base/views/widget/custom_button_widget.dart';
import '../../../base/views/widget/success_dialog.dart';
import '../../../core/router/app_router.dart';
import '../../../models/enums/project_role.dart';
import '../../../models/user_model.dart';
import '../../../utils/logger.dart';
import '../viewmodel/member_permissions_view_model.dart';

class MemberPermissionsScreen extends StatefulWidget {
  final List<ProjectMember>? members;
  final bool isEditMode;
  final String? projectId;

  const MemberPermissionsScreen({
    Key? key,
    this.members,
    required this.isEditMode,
    this.projectId,
  }) : super(key: key);


  @override
  _MemberPermissionsScreenState createState() => _MemberPermissionsScreenState();
}

class _MemberPermissionsScreenState extends State<MemberPermissionsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _removeOverlay();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<MemberPermissionsViewModel>();
      viewModel.loadCurrentUser();

      if (widget.isEditMode && widget.members != null) {
        viewModel.setInitialMembers(widget.members!);
      }
    });
  }


  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<MemberPermissionsViewModel>().searchUsers();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = value;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<MemberPermissionsViewModel>().updateSearchQuery(query);
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }



  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _removeOverlay();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          Positioned(
            width: size.width - 32,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, 60),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () {},
                  child: Consumer<MemberPermissionsViewModel>(
                    builder: (context, viewModel, _) {
                      return Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: viewModel.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : viewModel.searchResults.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Không tìm thấy người dùng",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                            : NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollUpdateNotification) {
                              CustomDropdown.closeAllDropdowns();
                            }
                            return true;
                          },
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: viewModel.searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey[200],
                            ),
                            itemBuilder: (context, index) {
                              final user = viewModel.searchResults[index];
                              return _buildCustomListTile(user, viewModel);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }






  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: AppColors.culTured,
  //     appBar: AppBar(
  //       leading: BackButton(),
  //       centerTitle: true,
  //       title: Text(
  //         widget.isEditMode ? 'Chỉnh sửa thành viên' : 'Thêm thành viên',
  //         style: const TextStyle(
  //           color: AppColors.stateGreen,
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             if (widget.isEditMode) {
  //               context.go('/project_detail/${widget.projectId}');
  //             } else {
  //               context.go('/project_management');
  //             }
  //           },
  //           child: const Text(
  //             'Huỷ  ',
  //             style: TextStyle(
  //               color: Colors.redAccent,
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //     ),
  //     body: SingleChildScrollView(
  //       child: Consumer<MemberPermissionsViewModel>(
  //         builder: (context, viewModel, child) {
  //           return Column(
  //             children: [
  //               SizedBox(height: 8),
  //               Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: CompositedTransformTarget(
  //                   link: _layerLink,
  //                   child: TextField(
  //                     controller: _searchController,
  //                     decoration: InputDecoration(
  //                       hintText: 'Tìm kiếm người dùng',
  //                       prefixIcon: Icon(Icons.search, color: Colors.grey),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(16),
  //                         borderSide: BorderSide(color: Colors.grey, width: 1),
  //                       ),
  //                       filled: true,
  //                       fillColor: Colors.white,
  //                     ),
  //                     onChanged: _onSearchChanged,
  //                     onTap: () {
  //                       if (_searchController.text.isNotEmpty) {
  //                         _showOverlay();
  //                       }
  //                     },
  //                     focusNode: FocusNode()..addListener(() {
  //                       if (!_isSearchFocused) {
  //                         _searchController.text = '';
  //                         _removeOverlay();
  //                       }
  //                     }),
  //                   ),
  //
  //                 ),
  //               ),
  //
  //
  //               Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 20),
  //                 child: Align(
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     'Thành viên',
  //                     style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: AppColors.black90,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //
  //               _buildMembersList(viewModel),
  //
  //               // Button
  //               Padding(
  //                 padding: const EdgeInsets.only(bottom: 60, left: 20, right: 20),
  //                 child: CustomButtonWidget(
  //                   isLoading: viewModel.isLoading,
  //                   text: widget.isEditMode ? 'Cập nhật' : 'Tiếp tục',
  //                   loadingText: widget.isEditMode ? 'Đang cập nhật...' : 'Đang xử lý...',
  //                   backgroundColor: AppColors.stateGreen,
  //                   onPressed: () async {
  //                     final success = await viewModel.saveMemberPermissions(isEditMode: widget.isEditMode, projectId: widget.projectId);
  //                     if (success) {
  //                       if (widget.isEditMode) {
  //                         showDialog(
  //                           context: context,
  //                           barrierDismissible: false,
  //                           builder: (context) => const SuccessDialog(
  //                             message: "Cập nhật thành công!",
  //                           ),
  //                         );
  //
  //                         await Future.delayed(const Duration(milliseconds: 2500));
  //                         context.pop();
  //                       } else {
  //                         context.push('/factor_level_project');
  //                       }
  //                     }
  //                   },
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.culTured,
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        title: Text(
          widget.isEditMode ? 'Chỉnh sửa thành viên' : 'Thêm thành viên',
          style: const TextStyle(
            color: AppColors.stateGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.isEditMode) {
                context.go('/project_detail/${widget.projectId}');
              } else {
                context.go('/project_management');
              }
            },
            child: const Text(
              'Huỷ  ',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<MemberPermissionsViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 8),
                  // Fixed search bar
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm người dùng',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _onSearchChanged,
                        onTap: () {
                          if (_searchController.text.isNotEmpty) {
                            _showOverlay();
                          }
                        },
                        focusNode: FocusNode()..addListener(() {
                          if (!_isSearchFocused) {
                            _searchController.text = '';
                            _removeOverlay();
                          }
                        }),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Thành viên',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black90,
                        ),
                      ),
                    ),
                  ),

                  // Scrollable members list with padding at bottom to avoid button overlap
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 80), // Add padding to avoid overlap with button
                      child: _buildMembersList(viewModel),
                    ),
                  ),
                ],
              ),

              // Fixed button at the bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: AppColors.culTured, // Match background to make it blend
                  child: CustomButtonWidget(
                    isLoading: viewModel.isLoading,
                    text: widget.isEditMode ? 'Cập nhật' : 'Tiếp tục',
                    loadingText: widget.isEditMode ? 'Đang cập nhật...' : 'Đang xử lý...',
                    backgroundColor: AppColors.stateGreen,
                    onPressed: () async {
                      final success = await viewModel.saveMemberPermissions(isEditMode: widget.isEditMode, projectId: widget.projectId);
                      if (success) {
                        if (widget.isEditMode) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const SuccessDialog(
                              message: "Cập nhật thành công!",
                            ),
                          );

                          await Future.delayed(const Duration(milliseconds: 2500));
                          context.pop();
                        } else {
                          context.push('/factor_level_project');
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildCustomListTile(User user, MemberPermissionsViewModel viewModel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage:AssetImage(AppImages.defaultAvatar) as ImageProvider,
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                CustomDropdown(userId: user.id, viewModel: viewModel),
              ],
            ),
          ),

          // Add button
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.green, size: 30),
            onPressed: () {
              viewModel.addMember(user);
              viewModel.removeMemberResult(user.id);
            },
          ),
        ],
      ),
    );
  }


  Widget _buildMembersList(MemberPermissionsViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: viewModel.displayMembers.length,
      itemBuilder: (context, index) {
        final member = viewModel.displayMembers[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  backgroundImage: member.urlAvatar != null && member.urlAvatar!.isNotEmpty
                      ? NetworkImage(member.urlAvatar!) as ImageProvider
                      : AssetImage(AppImages.defaultAvatar),
                ),
                SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name ?? 'No Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(member.email),
                      SizedBox(height: 4),
                      // Role
                      member.role == ProjectRole.OWNER
                          ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Owner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      )
                          : CustomDropdown(
                        userId: member.userId,
                        viewModel: viewModel,
                      ),
                    ],
                  ),
                ),

                if (member.role != ProjectRole.OWNER)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      viewModel.removeMember(member.userId);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }









  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
