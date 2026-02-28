// import 'package:flutter/material.dart';
// import 'package:hotel_management_app/providers/booking_provider.dart';
// import 'package:hotel_management_app/providers/guest_provider.dart';
// import 'package:hotel_management_app/providers/hr_provider.dart';
// import 'package:hotel_management_app/providers/inventory_provider.dart';
// import 'package:hotel_management_app/providers/payment_provider.dart';
// import 'package:hotel_management_app/providers/report_provider.dart';
// import 'package:hotel_management_app/providers/user_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:hotel_management_app/core/theme/app_theme.dart';
// import 'package:hotel_management_app/core/routes/app_routes.dart';
// import 'package:hotel_management_app/core/routes/route_generator.dart';
// import 'package:hotel_management_app/providers/auth_provider.dart';
// import 'package:hotel_management_app/providers/dashboard_provider.dart';
// import 'package:hotel_management_app/providers/room_provider.dart';  // ✅ Add this import
// import 'package:hotel_management_app/services/connectivity_service.dart';
// import 'package:hotel_management_app/services/navigation_service.dart';
// import 'package:hotel_management_app/data/local/preferences/shared_prefs_helper.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize services
//   await SharedPrefsHelper.init();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ConnectivityService()),
//         ChangeNotifierProvider(create: (_) => DashboardProvider()),
//         ChangeNotifierProvider(create: (_) => RoomProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => BookingProvider()),
//         ChangeNotifierProvider(create: (_) => InventoryProvider()),
//         ChangeNotifierProvider(create: (_) => HrProvider()),
//         ChangeNotifierProvider(create: (_) => ReportProvider()),
//         ChangeNotifierProvider(create: (_) => PaymentProvider()),
//         ChangeNotifierProvider(create: (_) => GuestProvider()),
//
//       ],
//       child: Consumer2<AuthProvider, ConnectivityService>(
//         builder: (context, authProvider, connectivityService, child) {
//           return MaterialApp(
//             title: 'Hotel Management',
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: ThemeMode.light,
//             initialRoute: authProvider.isLoggedIn
//                 ? AppRoutes.getInitialRoute(authProvider.userRole)
//                 : AppRoutes.splash,
//             onGenerateRoute: RouteGenerator.generateRoute,
//             navigatorKey: NavigationService.navigatorKey,
//             builder: (context, child) {
//               return Stack(
//                 children: [
//                   if (child != null) child,
//                   if (!connectivityService.isConnected)
//                     Positioned(
//                       bottom: 20,
//                       left: 20,
//                       right: 20,
//                       child: Container(
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           'No Internet Connection',
//                           style: TextStyle(color: Colors.white),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management_app/providers/booking_provider.dart';
import 'package:hotel_management_app/providers/dashboard_provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/providers/inventory_provider.dart';
import 'package:hotel_management_app/providers/payment_provider.dart';
import 'package:hotel_management_app/providers/report_provider.dart';
import 'package:hotel_management_app/providers/room_provider.dart';
import 'package:hotel_management_app/providers/hr_provider.dart';
import 'package:hotel_management_app/providers/inventory_provider.dart';
import 'package:hotel_management_app/providers/staff_provider.dart';
import 'package:hotel_management_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:hotel_management_app/core/theme/app_theme.dart';
import 'package:hotel_management_app/core/routes/app_routes.dart';
import 'package:hotel_management_app/core/routes/route_generator.dart';
import 'package:hotel_management_app/providers/auth_provider.dart';
import 'package:hotel_management_app/providers/guest_provider.dart';
import 'package:hotel_management_app/services/connectivity_service.dart';
import 'package:hotel_management_app/services/navigation_service.dart';
import 'package:hotel_management_app/data/local/preferences/shared_prefs_helper.dart';
import 'package:hotel_management_app/data/local/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await SharedPrefsHelper.init();


  final dbPath = await getDatabasesPath();
  await deleteDatabase('$dbPath/hotel_management.db');


  // Initialize database (demo data will be inserted automatically)
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  if (kDebugMode) {
    final dbHelper = DatabaseHelper();
    // await dbHelper.deleteDatabaseFile();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GuestProvider()..checkLoggedInUser()),
        ChangeNotifierProvider(create: (_) => StaffProvider()..checkLoggedInUser()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
  // Insert staff demo data after app starts
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(Duration(seconds: 1), () async {
      final staffProvider = StaffProvider();
      await staffProvider.insertStaffDemoData();
    });
  });

  // Add this to update database schema
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.addAssignedByColumn();

  });
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => HrProvider()),

        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),

      ],
      child: Consumer2<AuthProvider, ConnectivityService>(
        builder: (context, authProvider, connectivityService, child) {
          return MaterialApp(
            title: 'Hotel Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            navigatorKey: NavigationService.navigatorKey,
          );
        },
      ),
    );
  }
}