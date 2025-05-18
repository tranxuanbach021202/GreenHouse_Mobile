import 'package:flutter/material.dart';
import 'package:greenhouse/core/app_images.dart';
import '../../di/di.dart';
import '../../respositories/project_repository.dart';
import '../dashboard/project_short_model.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final ValueChanged<ProjectShort>? onProjectSelected;

  const SearchScreen({
    super.key,
    this.onClose,
    this.onProjectSelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ProjectRepository _projectRepository = getIt<ProjectRepository>();

  List<ProjectShort> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String keyword) async {
    setState(() => _isLoading = true);
    try {
      final data = await _projectRepository.searchProjects(keyword: keyword);
      final items = (data['content'] as List)
          .map((json) => ProjectShort.fromJson(json))
          .toList();
      setState(() {
        _results = items;
      });
    } catch (e) {
      setState(() => _results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) => _search(value),
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final project = _results[index];
                      return ListTile(
                        title: Text(
                          project.projectName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => widget.onProjectSelected?.call(project),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}