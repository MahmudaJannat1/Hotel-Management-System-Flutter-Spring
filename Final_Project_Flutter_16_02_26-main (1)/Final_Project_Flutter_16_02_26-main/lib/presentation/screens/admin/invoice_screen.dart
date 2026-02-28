// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:hotel_management_app/providers/payment_provider.dart';
// import 'package:hotel_management_app/data/models/payment_model.dart';
// import 'package:hotel_management_app/presentation/widgets/common_drawer.dart';
// import 'package:hotel_management_app/core/routes/app_routes.dart';
// import 'package:hotel_management_app/core/utils/currency_formatter.dart';
//
// import '../../../data/models/invoice_model.dart';
// import '../../../data/remote/services/invoice_print_service.dart';
//
// class InvoiceScreen extends StatefulWidget {
//   final Payment payment;
//
//   const InvoiceScreen({Key? key, required this.payment}) : super(key: key);
//
//   @override
//   _InvoiceScreenState createState() => _InvoiceScreenState();
// }
//
// class _InvoiceScreenState extends State<InvoiceScreen> {
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadInvoice();
//     });
//   }
//
//   Future<void> _loadInvoice() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//     final provider = Provider.of<PaymentProvider>(context, listen: false);
//     await provider.loadInvoiceByBooking(widget.payment.bookingId);
//     if (mounted) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _generateInvoice(BuildContext context, PaymentProvider provider) async {
//     if (!mounted) return;  // 🔥 শুরুতে check
//     setState(() => _isLoading = true);
//
//     final invoiceData = {
//       'bookingId': widget.payment.bookingId,
//       'dueDate': DateTime.now().add(Duration(days: 7)).toIso8601String().split('T')[0],
//       'roomCharges': widget.payment.amount,
//       'taxRate': 15.0,
//       'generatedBy': 'Admin',
//     };
//
//     final success = await provider.generateInvoice(invoiceData);
//
//     if (success && mounted) {  // 🔥 check
//       await provider.loadInvoiceByBooking(widget.payment.bookingId);
//     }
//
//     if (mounted) {  // 🔥 check
//       setState(() => _isLoading = false);
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Invoice generated successfully'),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _emailInvoice(BuildContext context, Invoice invoice) async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//
//     try {
//       // TODO: Implement actual email API call
//       await Future.delayed(Duration(seconds: 1));
//
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invoice sent to ${invoice.guestEmail}'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to send email: $e'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _printInvoice() async {
//     // TODO: Implement print functionality
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Print feature coming soon'),
//         backgroundColor: Colors.orange,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('Invoice'),
//         backgroundColor: Colors.blue[800],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           // 🔥 Print Button - Consumer-এর ভিতরে
//           Consumer<PaymentProvider>(
//             builder: (context, provider, child) {
//               final invoice = provider.selectedInvoice;
//               return IconButton(
//                 icon: Icon(Icons.print),
//                 onPressed: invoice != null
//                     ? () async {
//                   try {
//                     await InvoicePrintService.printInvoice(invoice);
//                     if (!mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Printing invoice...'),
//                         backgroundColor: Colors.blue,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   } catch (e) {
//                     if (!mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to print: $e'),
//                         backgroundColor: Colors.red,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   }
//                 }
//                     : null,
//                 color: invoice != null ? Colors.white : Colors.grey,
//               );
//             },
//           ),
//           // Email Button
//           Consumer<PaymentProvider>(
//             builder: (context, provider, child) {
//               final invoice = provider.selectedInvoice;
//               return IconButton(
//                 icon: Icon(Icons.email),
//                 onPressed: invoice != null
//                     ? () => _emailInvoice(context, invoice)
//                     : null,
//                 color: invoice != null ? Colors.white : Colors.grey,
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: CommonDrawer(currentRoute: AppRoutes.adminPayments),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Consumer<PaymentProvider>(
//         builder: (context, provider, child) {
//           final invoice = provider.selectedInvoice;
//
//           if (invoice == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.receipt_outlined, size: 60, color: Colors.grey[400]),
//                   SizedBox(height: 16),
//                   Text(
//                     'No invoice generated yet',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                   ),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () => _generateInvoice(context, provider),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue[800],
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                     ),
//                     child: Text('Generate Invoice'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return SingleChildScrollView(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'INVOICE',
//                                   style: TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue[800],
//                                   ),
//                                 ),
//                                 Text(
//                                   invoice.invoiceNumber,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: invoice.statusColor.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 invoice.status,
//                                 style: TextStyle(
//                                   color: invoice.statusColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Divider(height: 32),
//
//                         // Hotel & Guest Info
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'From:',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Sunrise Grand Hotel',
//                                     style: TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text('123 Hotel Street'),
//                                   Text('Dhaka, Bangladesh'),
//                                 ],
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Text(
//                                     'Bill To:',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     invoice.guestName,
//                                     style: TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(invoice.guestEmail),
//                                   Text(invoice.guestPhone),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 24),
//
//                         // Booking Details
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Booking: ${invoice.bookingNumber}',
//                                       style: TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     Text('Room: ${invoice.roomNumber}'),
//                                   ],
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'Check-in: ${invoice.checkInDate.day}/${invoice.checkInDate.month}/${invoice.checkInDate.year}',
//                                     ),
//                                     Text(
//                                       'Check-out: ${invoice.checkOutDate.day}/${invoice.checkOutDate.month}/${invoice.checkOutDate.year}',
//                                     ),
//                                     Text('${invoice.numberOfNights} nights'),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 24),
//
//                         // Charges Table
//                         Text(
//                           'Charges',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey[300]!),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             children: [
//                               _buildChargeRow(
//                                 'Room Charges',
//                                 invoice.roomCharges,
//                                 isHeader: true,
//                               ),
//                               if (invoice.foodCharges > 0)
//                                 _buildChargeRow(
//                                   'Food & Beverage',
//                                   invoice.foodCharges,
//                                 ),
//                               if (invoice.serviceCharges > 0)
//                                 _buildChargeRow(
//                                   'Service Charges',
//                                   invoice.serviceCharges,
//                                 ),
//                               if (invoice.taxAmount > 0)
//                                 _buildChargeRow(
//                                   invoice.taxDescription ?? 'Tax',
//                                   invoice.taxAmount,
//                                 ),
//                               if (invoice.discountAmount > 0)
//                                 _buildChargeRow(
//                                   'Discount',
//                                   -invoice.discountAmount,
//                                   color: Colors.red,
//                                 ),
//                               Divider(height: 1),
//                               _buildChargeRow(
//                                 'Total',
//                                 invoice.totalAmount,
//                                 isTotal: true,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Payment Summary
//                         Container(
//                           padding: EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             children: [
//                               _buildPaymentRow(
//                                 'Paid Amount',
//                                 invoice.paidAmount,
//                               ),
//                               _buildPaymentRow(
//                                 'Due Amount',
//                                 invoice.dueAmount,
//                                 isDue: true,
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 16),
//
//                         // Notes
//                         if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
//                           Text(
//                             'Notes:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 4),
//                           Text(invoice.notes!),
//                           SizedBox(height: 16),
//                         ],
//
//                         // Terms
//                         if (invoice.termsAndConditions != null &&
//                             invoice.termsAndConditions!.isNotEmpty) ...[
//                           Text(
//                             'Terms & Conditions:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             invoice.termsAndConditions!,
//                             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                           ),
//                         ],
//
//                         // Footer
//                         SizedBox(height: 24),
//                         Center(
//                           child: Text(
//                             'Thank you for your stay!',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[800],
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Center(
//                           child: Text(
//                             'Generated on: ${invoice.createdAt.day}/${invoice.createdAt.month}/${invoice.createdAt.year}',
//                             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildChargeRow(String label, double amount,
//       {bool isHeader = false, bool isTotal = false, Color? color}) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: isHeader ? 12 : 8),
//       decoration: BoxDecoration(
//         color: isHeader ? Colors.grey[200] : null,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             CurrencyFormatter.format(amount),
//             style: TextStyle(
//               fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
//               color: color ?? (isTotal ? Colors.blue[800] : Colors.black),
//               fontSize: isTotal ? 16 : 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPaymentRow(String label, double amount, {bool isDue = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label),
//           Text(
//             CurrencyFormatter.format(amount),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: isDue
//                   ? (amount > 0 ? Colors.red : Colors.green)
//                   : Colors.green,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }