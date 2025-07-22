import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/screens/form/batches_form.dart';
import 'package:tracking_app/screens/form/daily_record_form.dart';
import 'package:tracking_app/screens/form/disease_detection.dart';
import 'package:tracking_app/screens/form/disease_form.dart';
import 'package:tracking_app/screens/form/harvested_form.dart';
import 'package:tracking_app/screens/form/product_info_form.dart';
import 'package:tracking_app/services/auth_service.dart';
import '../models/drawer_item.dart';
import '../screens/form/greenhouse_info_form.dart';

class DrawerConfig {
  static List<DrawerItem> getUserDrawerItems(BuildContext context) {
    return [
      DrawerItem(
        title: 'Daily Record',
        icon: Icons.assignment,
        onTap: () => _navigateToDailyRecord(context),
      ),
      DrawerItem(
        title: 'New Batch',
        icon: Icons.assignment,
        onTap: () => _navigateToNewBatch(context),
      ),
      DrawerItem(
        title: 'Harvested Information',
        icon: Icons.assignment,
        onTap: () => _navigateToHarvestedInfo(context),
      ),
      DrawerItem(
        title: 'Product Information',
        icon: Icons.assignment,
        onTap: () => _navigateToProductInfo(context),
      ),
      DrawerItem(
        title: 'Disease Detection',
        icon: Icons.assignment,
        onTap: () => _navigateToDiseaseDectection(context),
      ),
      DrawerItem(
        title: 'Add Disease',
        icon: Icons.bug_report,
        onTap: () => _navigateToAddDisease(context),
      ),
      DrawerItem.divider(),
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        iconColor: Colors.red,
        onTap: () => _handleLogout(context),
        isLogout: true,
      ),
    ];
  }

  static List<DrawerItem> getAdminDrawerItems(BuildContext context) {
    return [
      DrawerItem(
        title: 'Daily Record',
        icon: Icons.assignment,
        onTap: () => _navigateToDailyRecord(context),
      ),
      DrawerItem(
        title: 'New Batch',
        icon: Icons.assignment,
        onTap: () => _navigateToNewBatch(context),
      ),
      DrawerItem(
        title: 'Harvested Information',
        icon: Icons.assignment,
        onTap: () => _navigateToHarvestedInfo(context),
      ),
      DrawerItem(
        title: 'Product Information',
        icon: Icons.assignment,
        onTap: () => _navigateToProductInfo(context),
      ),
      DrawerItem(
        title: 'Disease Detection',
        icon: Icons.assignment,
        onTap: () => _navigateToDiseaseDectection(context),
      ),
      DrawerItem(
        title: 'Add Disease',
        icon: Icons.bug_report,
        onTap: () => _navigateToAddDisease(context),
      ),
      DrawerItem(
        title: 'Greenhouse Information',
        icon: Icons.assignment,
        onTap: () => _navigateToGreenhouseInfo(context),
      ),
      DrawerItem.divider(),
      DrawerItem(
        title: 'Logout',
        icon: Icons.logout,
        iconColor: Colors.red,
        onTap: () => _handleLogout(context),
        isLogout: true,
      ),
    ];
  }

  static void _navigateToDailyRecord(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyRecordForm()),
    );
  }

  static void _navigateToNewBatch(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BatchesForm()),
    );
  }

  static void _navigateToHarvestedInfo(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HarvestedForm()),
    );
  }

  static void _navigateToProductInfo(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (centext) => const ProductInfoForm()),
    );
  }

  static void _navigateToDiseaseDectection(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (centext) => const DiseaseDetectionForm()),
    );
  }

  static void _navigateToGreenhouseInfo(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GreenhouseInfoForm()),
    );
  }

  static void _navigateToAddDisease(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DiseaseForm()),
    );
  }

  static void _handleLogout(BuildContext context) {
    Navigator.pop(context);
    _showLogoutDialog(context);
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Logout',
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logging out...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // Call AuthService logout
                  await context.read<AuthService>().logout();

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              )
            ],
          );
        });
  }
}
