import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse/utils/logger.dart';

import '../../../models/enums/project_role.dart';
import '../../../models/user_model.dart';
import '../viewmodel/member_permissions_view_model.dart';

class CustomDropdown extends StatefulWidget {
  final String userId;
  final MemberPermissionsViewModel viewModel;

  CustomDropdown({required this.userId, required this.viewModel});

  static final List<_CustomDropdownState> _openDropdowns = [];

  static void closeAllDropdowns() {
    final dropdowns = List.from(_openDropdowns);
    for (var dropdown in dropdowns) {
      dropdown._removeOverlay();
    }
  }

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.viewModel.getUserRole(widget.userId) == ProjectRole.MEMBER ? 'Member' : 'Guest',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    _isOpen = !_isOpen;
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
    CustomDropdown._openDropdowns.add(this);
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
      CustomDropdown._openDropdowns.remove(this);
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => UnconstrainedBox(
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, 30),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuItem(
                    'Member',
                        () {
                      logger.i("Members");
                      widget.viewModel.updateUserRole(widget.userId, ProjectRole.MEMBER);
                      _removeOverlay();
                    },
                  ),
                  Divider(height: 1),
                  _buildMenuItem(
                    'Guest',
                        () {
                      logger.i("Guest");
                      widget.viewModel.updateUserRole(widget.userId, ProjectRole.GUEST);
                      _removeOverlay();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600,),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
