import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isCollapsed ? 70 : 200,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // App Title
          if (!_isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "CookWise",
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 28,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            ),

          if (_isCollapsed)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.restaurant_menu,
                color: AppColors.mainColor,
                size: 28,
              ),
            ),

          const Divider(color: Color.fromARGB(255, 188, 187, 187)),

          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.kitchen, "Pantry", 1),
                _buildNavItem(Icons.shopping_cart, "Shopping List", 2),
                _buildNavItem(Icons.person, "Profile", 3),
              ],
            ),
          ),

          // Collapse/Expand Button
          IconButton(
            icon: Icon(
              _isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isCollapsed = !_isCollapsed;
              });
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ------------------ Navigation Item ------------------
  Widget _buildNavItem(IconData icon, String title, int index) {
    bool selected = widget.selectedIndex == index;

    return InkWell(
      onTap: () => widget.onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: selected
            ? BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              )
            : const BoxDecoration(),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Icon(icon, color: const Color.fromARGB(255, 7, 7, 7)),
            if (!_isCollapsed) const SizedBox(width: 16),
            if (!_isCollapsed)
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Color.fromARGB(255, 7, 7, 7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
