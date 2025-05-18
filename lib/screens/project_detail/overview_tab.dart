

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/screens/project_detail/viewmodel/project_detail_view_model.dart';
import 'package:greenhouse/screens/project_detail/widget/description_card_widget.dart';
import 'package:greenhouse/screens/project_detail/widget/member_card_widget.dart';
import 'package:greenhouse/screens/project_detail/widget/parameters_card_widget.dart';
import 'package:greenhouse/screens/project_detail/widget/section_header_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_images.dart';
import '../../models/project_member.dart';
import '../../models/response/project_response.dart';

class OverviewTab extends StatelessWidget {
  final ProjectResponse project;

  const OverviewTab({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ProjectDetailViewModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderWidget(
            title: "Mô tả dự án",
            iconData: viewModel.isOwner ? Icons.edit : null,
            onPressed: () async {
              final updated = await context.push<bool>(
                '/general_info_project',
                extra: {
                  'isEditMode': true,
                  'project': project,
                },
              );

              if (updated == true) {
                context.read<ProjectDetailViewModel>().reload();
              }

            },
          ),
          const SizedBox(height: 12),
          DescriptionCardWidget(
            title: project.name,
            description: project.description,
            timeframe: '${DateFormat('d/M/yyyy').format(project.startDate)} -'
                ' ${DateFormat('d/M/yyyy').format(project.endDate)}',
          ),

          const SizedBox(height: 24),
          SectionHeaderWidget(
            title: "Thành viên",
            iconData: viewModel.isOwner ? Icons.edit : null,
            onPressed: () {
              final List<ProjectMember> converted = project.members
                  .map((e) => ProjectMember.fromResponse(e))
                  .toList();

              context.push('/member_permissions_project', extra: {
                'isEditMode': true,
                'projectId': project.id,
                'members': converted,
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: project.members.length,
              itemBuilder: (context, index) {
                final member = project.members[index];
                Color roleColor;

                // Xác định màu sắc dựa trên vai trò
                switch (member.role) {
                  case 'OWNER':
                    roleColor = Colors.green;
                    break;
                  case 'MEMBER':
                    roleColor = Colors.blue;
                    break;
                  case 'GUEST':
                    roleColor = Colors.amber;
                    break;
                  default:
                    roleColor = Colors.grey;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: MemberCardWidget(
                    name: member.userName,
                    email: member.email,
                    role: member.role,
                    roleColor: roleColor,
                    imagePath: member.urlAvatar.isEmpty ? "" : member.urlAvatar,
                    onMorePressed: () {
                      // Handle more options
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SectionHeaderWidget(
            title: "Thông số",
            iconData: viewModel.isOwner ? Icons.edit : null,
            onPressed: () {
              context.push('/factor_level_project', extra: {
                'project' : project,
                'isEditMode': true,
              });
            },
          ),
          const SizedBox(height: 12),
          ParametersCardWidget(
            title: 'Yếu tố và mức độ',
            parameters: [
              ParameterRow(
                label1: 'Nhân tố',
                value1: project.factor.factorName ?? 'Chưa thiết lập',
                label2: 'Mã nhân tố',
                value2: project.factor.factorCode ?? 'Chưa thiết lập'
              ),
              ...project.factor.levels.map((level) =>
                ParameterRow(
                  label1: 'Mức độ',
                  value1: level.levelName,
                  label2: 'Mã mức độ',
                  value2: level.levelCode
                )
              ).toList(),
            ],
          ),

          const SizedBox(height: 16),
          ParametersCardWidget(
            title: 'Chỉ tiêu',
            parameters: project.criteria.isEmpty
              ? [ParameterRow(label1: 'Chỉ tiêu', value1: 'Chưa thiết lập', label2: 'Mã chỉ tiêu', value2: 'Chưa thiết lập')]
              : project.criteria.map((criterion) =>
                  ParameterRow(
                    label1: 'Chỉ tiêu',
                    value1: criterion.criterionName,
                    label2: 'Mã chỉ tiêu',
                    value2: criterion.criterionCode
                  )
                ).toList(),
          ),
        ],
      ),
    );
  }

}
