import 'package:flutter/material.dart';
import 'package:hotel_management_app/presentation/screens/splash/splash_screen.dart';
import 'package:hotel_management_app/presentation/screens/auth/login_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/guest_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/guest/room_list_screen.dart';
import 'package:hotel_management_app/presentation/screens/staff/staff_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/manager/manager_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/admin_home_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/user_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/room_management_screen.dart';
import 'package:hotel_management_app/presentation/screens/admin/booking_management_screen.dart';  // ✅ Add this
import 'package:hotel_management_app/presentation/screens/admin/add_edit_booking_screen.dart';  // ✅ Add this
import 'app_routes.dart';
import 'package:hotel_management_app/services/navigation_service.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case AppRoutes.guestHome:
        return MaterialPageRoute(builder: (_) => GuestHomeScreen());
      case AppRoutes.guestRoomList:
        return MaterialPageRoute(builder: (_) => RoomListScreen());
      case AppRoutes.staffHome:
        return MaterialPageRoute(builder: (_) => StaffHomeScreen());
      case AppRoutes.managerHome:
        return MaterialPageRoute(builder: (_) => ManagerHomeScreen());
      case AppRoutes.adminHome:
        return MaterialPageRoute(builder: (_) => AdminHomeScreen());
      case AppRoutes.adminUsers:
        return MaterialPageRoute(builder: (_) => UserManagementScreen());
      case AppRoutes.adminRooms:
        return MaterialPageRoute(builder: (_) => RoomManagementScreen());
      case AppRoutes.adminBookings:
        return MaterialPageRoute(builder: (_) => BookingManagementScreen());
      case AppRoutes.adminAddBooking:
        return MaterialPageRoute(builder: (_) => AddEditBookingScreen());
      case AppRoutes.adminBookingDetails:
        final bookingId = settings.arguments as int?;
        return MaterialPageRoute(
          builder: (_) => AddEditBookingScreen(
              bookingId: bookingId,
              isViewOnly: true),
        );
      case AppRoutes.adminAddBooking:
        return MaterialPageRoute(
          builder: (_) => AddEditBookingScreen(
            isViewOnly: false,
          ),
        );
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute([String? name]) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: Text('Error'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 16),
              Text('Page not found!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (name != null) ...[
                SizedBox(height: 8),
                Text('Route: $name', style: TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      );
    });
  }
}