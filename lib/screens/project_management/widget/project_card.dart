import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:greenhouse/models/response/project_model_response.dart';
import 'package:intl/intl.dart';


class ProjectCard extends StatelessWidget {
  final ProjectModelResponse project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Calculate project progress percentage based on time
    final now = DateTime.now();
    final totalDuration = project.endDate.difference(project.startDate).inDays;
    final elapsedDuration = now.difference(project.startDate).inDays;

    // Calculate progress value (between 0.0 and 1.0)
    double progressValue;
    if (now.isBefore(project.startDate)) {
      // Project hasn't started yet
      progressValue = 0.0;
    } else if (now.isAfter(project.endDate)) {
      // Project has ended
      progressValue = 1.0;
    } else {
      // Project is in progress
      progressValue = elapsedDuration / totalDuration;
      // Ensure value is between 0 and 1
      progressValue = progressValue.clamp(0.0, 1.0);
    }

    // Progress color based on completion
    Color progressColor;
    if (progressValue >= 1.0) {
      progressColor = Colors.red; // Completed or overdue
    } else if (progressValue > 0.75) {
      progressColor = Colors.orange; // Near completion
    } else {
      progressColor = Colors.green; // In progress
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.push('/project_detail/${project.id}');
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  project.thumbnailUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.projectName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...project.members.take(3).map(
                              (e) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(e.urlAvatar)),
                          ),
                        ),
                        if (project.members.length > 3)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: CircleAvatar(radius: 12, child: Text('50+')),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Từ: ${DateFormat('dd/MM').format(project.startDate)} - ${DateFormat('dd/MM').format(project.endDate)}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                        Text(
                          '${(progressValue * 100).toInt()}%',
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


// context.push('/project_detail/${project.id}');