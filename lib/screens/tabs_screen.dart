import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/services/auth_service.dart';
import 'package:tracking_app/widgets/custom_nav_bar.dart';
import '../models/user.dart';
import '../widgets/custom_drawer.dart';
import '../screens/dashboard.dart';
import '../screens/greenhouse.dart';
import '../screens/disease.dart';

class TabsScreen extends StatefulWidget {
  final User user;

  const TabsScreen({super.key, required this.user});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final List<String> _titles = ['Dashboard', 'Greenhouse', 'Diseases'];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animate to the selected page with a smooth sliding animation
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: AppColors.darkPrimary,
              size: 28,
            ),
            offset: const Offset(0, 40),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.darkPrimary),
                    const SizedBox(width: 8),
                    Text(widget.user.name),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.darkPrimary),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed == true) {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  await authService.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: CustomDrawer(user: widget.user),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              children: [
                _buildDashboard(),
                _buildGreenhouse(),
                _buildDisease(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(
              selectedIndex: _selectedIndex,
              onTabSelected: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Dashboard(user: widget.user);
  }

  Widget _buildGreenhouse() {
    return GreenhouseScreen(user: widget.user);
  }

  Widget _buildDisease() {
    return DiseaseScreen(user: widget.user);
  }
}
