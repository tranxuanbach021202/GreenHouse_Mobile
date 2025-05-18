import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/dashboard/project_short_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
class ProjectCard extends StatelessWidget {
  final ProjectShort project;
  final bool isDetailCard;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.isDetailCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/project_detail/${project.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Stack(
          children: [
            // Ảnh nền
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (project.thumbnailUrl == null || project.thumbnailUrl!.isEmpty)
                  ? Container(
                height: 180.h,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
              )
                  : Image.network(
                project.thumbnailUrl!,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180.h,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180.h,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                  );
                },
              ),
            ),

            // Thông tin overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16), top: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên project
                    Text(
                      project.projectName,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),

                    // Số lượng user
                    Row(
                      children: [
                        Icon(Icons.people, size: 14.sp, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                          (project.members?.length ?? 0).toString(),
                          style: TextStyle(color: Colors.green, fontSize: 12.sp),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    // Thời gian
                    Text(
                      "${DateFormat('dd/MM/yyyy').format(project.startDate)} - ${DateFormat('dd/MM/yyyy').format(project.endDate)}",
                      style: TextStyle(
                        color: Colors.orange.shade400,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}