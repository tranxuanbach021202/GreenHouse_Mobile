
import 'package:flutter/material.dart';
import 'package:greenhouse/screens/dashboard/project_short_model.dart';
import 'package:intl/intl.dart';

import '../../../models/response/project_response.dart';

class ProjectSearchOverlay extends StatelessWidget {
  final List<ProjectShort> projects;
  final void Function(ProjectShort project) onSelect;

  const ProjectSearchOverlay({
    Key? key,
    required this.projects,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 80, left: 16, right: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          constraints: BoxConstraints(maxHeight: 400),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: projects.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final project = projects[index];
              final dateFormat = DateFormat('dd/MM/yyyy');
              return ListTile(
                onTap: () => onSelect(project),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    project.thumbnailUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.image, size: 48),
                  ),
                ),
                title: Text(
                  project.projectName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}