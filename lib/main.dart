import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'services/auth_service.dart';
import 'services/batch_service.dart';
import 'services/product_service.dart';
import 'services/greenhouse_service.dart';
import 'services/api_service.dart';
import 'providers/batch_provider.dart';
import 'providers/greenhouse_provider.dart';
import 'screens/login_page.dart';
import 'screens/tabs_screen.dart';
import 'models/user.dart';
import 'widgets/custom_drawer.dart';
import 'providers/dashboard_provider.dart';
import 'services/harvested_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (context) => ApiService(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => AuthService(),
          lazy: false,
        ),
        ProxyProvider<ApiService, BatchService>(
          update: (context, apiService, previous) => BatchService(apiService),
        ),
        ProxyProvider<ApiService, ProductService>(
          update: (context, apiService, previous) => ProductService(apiService),
        ),
        ProxyProvider<ApiService, GreenhouseService>(
          update: (context, apiService, previous) =>
              GreenhouseService(apiService: apiService),
        ),
        ProxyProvider<ApiService, HarvestedService>(
          update: (context, apiService, previous) =>
              HarvestedService(apiService: apiService),
        ),
        ChangeNotifierProxyProvider2<BatchService, ProductService,
            BatchProvider>(
          create: (context) => BatchProvider(
            context.read<BatchService>(),
            context.read<ProductService>(),
          ),
          update: (context, batchService, productService, previous) =>
              previous ?? BatchProvider(batchService, productService),
        ),
        ChangeNotifierProxyProvider<GreenhouseService, GreenhouseProvider>(
          create: (context) =>
              GreenhouseProvider(context.read<GreenhouseService>()),
          update: (context, greenhouseService, previous) =>
              previous ?? GreenhouseProvider(greenhouseService),
        ),
        ChangeNotifierProxyProvider3<BatchService, HarvestedService,
            ProductService, DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<BatchService>(),
            context.read<HarvestedService>(),
            context.read<ProductService>(),
          ),
          update: (context, batchService, harvestedService, productService,
                  previous) =>
              previous ??
              DashboardProvider(batchService, harvestedService, productService),
        ),
      ],
      child: MaterialApp(
        title: 'Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: GoogleFonts.getFont('Montserrat').fontFamily,
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('Initializing authentication', name: 'AuthWrapper');
      context.read<AuthService>().initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        developer.log(
          'Auth state updated',
          name: 'AuthWrapper',
          error: authService.isAuthenticated ? null : 'Not authenticated',
        );

        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authService.isAuthenticated) {
          return const LoginPage();
        }

        return TabsScreen(user: authService.currentUser!);
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: CustomDrawer(user: user),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to the App!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          if (user.lastLogin != null)
            Text(
              'Last login: ${_formatDate(user.lastLogin!)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthService>().logout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
