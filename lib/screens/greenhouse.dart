import 'package:flutter/material.dart';
import 'package:tracking_app/models/user.dart';
import 'package:tracking_app/models/greenhouse.dart';
import 'package:tracking_app/widgets/greenhouse_card.dart';
import 'package:tracking_app/constrants/app_colors.dart';
import 'package:tracking_app/screens/greenhouse_details_screen.dart';
import 'package:tracking_app/services/greenhouse_service.dart';
import 'package:tracking_app/screens/form/greenhouse_info_form.dart';

class GreenhouseScreen extends StatefulWidget {
  final User user;

  const GreenhouseScreen({super.key, required this.user});

  @override
  State<GreenhouseScreen> createState() => _GreenhouseScreenState();
}

class _GreenhouseScreenState extends State<GreenhouseScreen> {
  List<Greenhouse> _greenhouses = [];
  bool _isLoading = true;
  String? _error;
  final _greenhouseService = GreenhouseService();

  @override
  void initState() {
    super.initState();
    _loadGreenhouses();
  }

  Future<void> _loadGreenhouses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final greenhouses = await _greenhouseService.getAllGreenhouses();
      if (!mounted) return;
      setState(() {
        _greenhouses = greenhouses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addGreenhouse() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GreenhouseInfoForm()),
    );

    if (result == true) {
      _loadGreenhouses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGreenhouses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadGreenhouses,
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Greenhouses Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_greenhouses.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Text(
                                widget.user.role == 'ADMIN'
                                    ? 'No greenhouses found.\nTap the + button to create one.'
                                    : 'No greenhouses found.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _greenhouses.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.2,
                            ),
                            itemBuilder: (context, index) {
                              final greenhouse = _greenhouses[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          GreenhouseDetailsScreen(
                                        greenhouseId: greenhouse.greenhouseId,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _loadGreenhouses();
                                    }
                                  });
                                },
                                child: GreenhouseCard(greenhouse: greenhouse),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: widget.user.role == 'ADMIN'
          ? FloatingActionButton(
              onPressed: _addGreenhouse,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
