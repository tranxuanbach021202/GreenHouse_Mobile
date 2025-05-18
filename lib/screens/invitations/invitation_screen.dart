import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:greenhouse/core/app_images.dart';
import 'package:greenhouse/di/di.dart';
import 'package:greenhouse/screens/invitations/viewmodel/invitation_view_model.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../models/invitation_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../respositories/invitation_repository.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  late InvitationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = GetIt.I<InvitationViewModel>();
    viewModel.fetchInvitations();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: AppColors.culTured,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Lời Mời Tham Gia Dự Án',
            style: TextStyle(
              color: AppColors.stateGreen,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<InvitationViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.stateGreen),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  'Đã xảy ra lỗi',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  viewModel.error ?? 'Không thể tải lời mời',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => viewModel.fetchInvitations(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.stateGreen,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (viewModel.invitations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'Không có lời mời nào',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Bạn sẽ nhận được thông báo khi có lời mời mới',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: viewModel.invitations.length,
          itemBuilder: (context, index) {
            final invite = viewModel.invitations[index];
            return _buildInvitationCard(invite, viewModel);
          },
        );
      },
    );
  }

  Widget _buildInvitationCard(InvitationModel invite, InvitationViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectImage(invite),
                SizedBox(width: 10.w), // Giảm từ 12.w
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invite.projectName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.stateGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Text(
                            invite.inviterName,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.w), // Giảm từ 8.w
                            width: 3.r, // Giảm từ 4.r
                            height: 3.r, // Giảm từ 4.r
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            _timeAgo(invite.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12.sp, // Giảm từ 14.sp
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h), // Giảm từ 8.h
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppColors.stateGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'Vai trò: ${invite.role}',
                          style: TextStyle(
                            color: AppColors.stateGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => viewModel.acceptInvitation(invite.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.stateGreen,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => viewModel.rejectInvitation(invite.id),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(vertical: 8.h), // Giảm từ 12.h
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r), // Giảm từ 12.r
                      ),
                    ),
                    child: Text(
                      'Từ chối',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp, // Giảm từ 16.sp
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProjectImage(InvitationModel invite) {
    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: invite.thumbnailUrlProject != null &&
                invite.thumbnailUrlProject!.startsWith('http')
            ? Image.network(
                invite.thumbnailUrlProject!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.stateGreen.withOpacity(0.1),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.stateGreen,
                      size: 24.sp,
                    ),
                  );
                },
              )
            : Container(
                color: AppColors.stateGreen.withOpacity(0.1),
                child: Icon(
                  Icons.folder_outlined,
                  color: AppColors.stateGreen,
                  size: 24.sp,
                ),
              ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months tháng trước';
    } else if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
