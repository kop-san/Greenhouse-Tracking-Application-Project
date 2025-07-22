import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/drawer_item.dart';
import '../config/drawer_config.dart';
import '../constrants/app_colors.dart';
import 'drawer_header_widget.dart';
import 'drawer_item_widget.dart';

class CustomDrawer extends StatelessWidget {
  final User user;

  const CustomDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    List<DrawerItem> drawerItems = user.isAdmin
        ? DrawerConfig.getAdminDrawerItems(context)
        : DrawerConfig.getUserDrawerItems(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            color: AppColors.primary,
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 10,
              bottom: 16,
            ),
            child: DrawerHeaderWidget(user: user),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  final item = drawerItems[index];

                  if (item.isDivider) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFE0E0E0),
                      ),
                    );
                  }

                  return DrawerItemWidget(item: item);
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
