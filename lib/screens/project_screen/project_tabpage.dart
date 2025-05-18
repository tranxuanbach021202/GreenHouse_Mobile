import 'package:flutter/material.dart';
class ProjectTabPage extends StatefulWidget {
  const ProjectTabPage({Key? key})
      : super(
    key: key,
  );

  @override
  ProjectTabPageState createState() => ProjectTabPageState();
}

class ProjectTabPageState extends State<ProjectTabPage> {
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: 24),
          _buildTaskList(context),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildTaskList(BuildContext context) {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 16,
        );
      },
      itemCount: 3,
      itemBuilder: (context, index) {
      },
    );
  }
}