import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracking_app/models/user.dart';
import 'package:tracking_app/providers/dashboard_provider.dart';
import 'package:tracking_app/services/api_service.dart';
import 'package:tracking_app/services/batch_service.dart';
import 'package:tracking_app/services/harvested_service.dart';
import 'package:tracking_app/services/product_service.dart';
import 'package:tracking_app/widgets/app_dropdown.dart';
import 'package:tracking_app/widgets/dashboard_card.dart';
import 'package:tracking_app/constrants/app_colors.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final DashboardProvider _dashboardProvider;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    final apiService = ApiService();
    _dashboardProvider = DashboardProvider(
      BatchService(apiService),
      HarvestedService(apiService: apiService),
      ProductService(apiService),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await _dashboardProvider.loadData();
  }

  Future<void> _handleRefresh() async {
    try {
      await _dashboardProvider.loadData();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${error.toString()}'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                _refreshIndicatorKey.currentState?.show();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _dashboardProvider,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.getDashboardData().isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.getDashboardData().isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final currentData = provider.getDashboardData();

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDropdown<String>(
                    value: provider.selectedProductType,
                    items: provider.productTypes,
                    itemLabel: (type) => type,
                    onChanged: provider.setSelectedProductType,
                    labelText: 'Filter by Product Type',
                    hintText: 'Select product type',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quantity Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 150.0,
                    ),
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> quantityCards = [
                        {
                          'title': 'Planted Quantity',
                          'value': currentData['plantedQuantity'],
                          'icon': Icons.grass,
                          'color': Colors.green,
                        },
                        {
                          'title': 'Product Quantity',
                          'value': currentData['productQuantity'],
                          'icon': Icons.agriculture,
                          'color': AppColors.primary,
                        },
                        {
                          'title': 'Damaged Quantity',
                          'value': currentData['damagedQuantity'],
                          'icon': Icons.broken_image,
                          'color': Colors.red,
                        },
                      ];
                      final cardData = quantityCards[index];
                      return DashboardCard(
                        title: cardData['title'],
                        value: cardData['value'],
                        icon: cardData['icon'],
                        color: cardData['color'],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quality Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 130.0,
                    ),
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> qualityCards = [
                        {
                          'title': 'Good Quality',
                          'value': currentData['goodQuality'],
                          'icon': Icons.check_circle,
                          'color': Colors.lightGreen,
                        },
                        {
                          'title': 'Bad Quality',
                          'value': currentData['badQuality'],
                          'icon': Icons.cancel,
                          'color': Colors.orange,
                        },
                        {
                          'title': 'Grade A',
                          'value': currentData['gradeA'],
                          'icon': Icons.star,
                          'color': Colors.amber,
                        },
                        {
                          'title': 'Grade B',
                          'value': currentData['gradeB'],
                          'icon': Icons.star_half,
                          'color': Colors.blueGrey,
                        },
                      ];
                      final cardData = qualityCards[index];
                      return DashboardCard(
                        title: cardData['title'],
                        value: cardData['value'],
                        icon: cardData['icon'],
                        color: cardData['color'],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
