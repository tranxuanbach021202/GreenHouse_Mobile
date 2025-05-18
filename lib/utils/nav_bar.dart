import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int pageIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.pageIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.green,
      child: SizedBox(
        height: 20,
        child: Row(
          children: [
            navItem(Icons.home_outlined, "Trang chủ", pageIndex == 0, () => onTap(0)),
            navItem(Icons.list_alt, "Dự án", pageIndex == 1, () => onTap(1)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 28),
                  Text(
                    "Scan QR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            navItem(Icons.add_task, "Lời mời", pageIndex == 2, () => onTap(2)),
            navItem(Icons.person_outline, "Tài khoản", pageIndex == 3, () => onTap(3)),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, bool selected, Function() onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: selected ? Colors.white : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
