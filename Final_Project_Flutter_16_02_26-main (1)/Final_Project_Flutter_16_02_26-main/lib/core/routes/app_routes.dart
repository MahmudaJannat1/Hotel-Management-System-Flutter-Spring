class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Guest routes
  static const String guestHome = '/guest/home';
  static const String guestRoomList = '/guest/rooms';
  static const String guestRoomDetails = '/guest/room-details';
  static const String guestBooking = '/guest/booking';
  static const String guestMyBookings = '/guest/my-bookings';

  // Staff routes
  static const String staffHome = '/staff/home';
  static const String staffTasks = '/staff/tasks';
  static const String staffAttendance = '/staff/attendance';

  // Manager routes
  static const String managerHome = '/manager/home';
  static const String managerTeam = '/manager/team';
  static const String managerReports = '/manager/reports';

  // Admin routes
  static const String adminHome = '/admin/home';
  static const String adminRooms = '/admin/rooms';
  static const String adminAddEditRoom = '/admin/rooms/add-edit';
  static const String adminUsers = '/admin/users';
  static const String adminAddEditUser = '/admin/users/add-edit';
  static const String adminBookings = '/admin/bookings';
  static const String adminInventory = '/admin/inventory';
  static const String adminHr = '/admin/hr';
  static const String adminReports = '/admin/reports';

  static const String adminSettings = '/admin/settings';
  static const String adminAddBooking = '/admin/bookings/add';
  static const String adminBookingDetails = '/admin/bookings/details';

  static const String adminPayments = '/admin/payments';
  static const String adminAddPayment = '/admin/payments/add';
  static const String adminPaymentDetails = '/admin/payments/details';
  static const String adminInvoices = '/admin/invoices';
  static const String adminInvoiceDetails = '/admin/invoices/details';


  static String getInitialRoute(String? role) {
    switch (role) {
      case 'ADMIN':
        return adminHome;
      case 'MANAGER':
        return managerHome;
      case 'STAFF':
        return staffHome;
      case 'GUEST':
        return guestHome;
      default:
        return splash;
    }
  }
}