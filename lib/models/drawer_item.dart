import 'package:flutter/material.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isDivider;
  final bool isLogout;

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.isDivider = false,
    this.isLogout = false,
  });

  static DrawerItem divider() {
    return DrawerItem(
      title: '',
      icon: Icons.remove,
      onTap: () {},
      isDivider: true,
    );
  }
}
