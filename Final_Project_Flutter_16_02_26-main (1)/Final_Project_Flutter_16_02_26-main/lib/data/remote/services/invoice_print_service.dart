// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:hotel_management_app/data/models/invoice_model.dart';
// import 'package:hotel_management_app/core/utils/currency_formatter.dart';
//
// class InvoicePrintService {
//   static Future<void> printInvoice(Invoice invoice) async {
//     final pdf = await _generatePdf(invoice);
//     await Printing.layoutPdf(
//       onLayout: (format) async => pdf,
//       name: 'Invoice_${invoice.invoiceNumber}.pdf',
//     );
//   }
//
//   static Future<Uint8List> _generatePdf(Invoice invoice) async {
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'INVOICE',
//                       style: pw.TextStyle(
//                         fontSize: 32,
//                         fontWeight: pw.FontWeight.bold,
//                         color: PdfColors.blue800,
//                       ),
//                     ),
//                     pw.Text(invoice.invoiceNumber),
//                   ],
//                 ),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColor.fromInt(0x1A2196F3),
//                     borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
//                   ),
//                   child: pw.Text(
//                     invoice.status,
//                     style: pw.TextStyle(
//                       color: PdfColors.blue800, // Solid color for text
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 20),
//
//           // Hotel & Guest Info
//           pw.Row(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Expanded(
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       'From:',
//                       style: pw.TextStyle(
//                         fontSize: 10,
//                         color: PdfColors.grey600,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       'Sunrise Grand Hotel',
//                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                     ),
//                     pw.Text('123 Hotel Street'),
//                     pw.Text('Dhaka, Bangladesh'),
//                   ],
//                 ),
//               ),
//               pw.Expanded(
//                 child: pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   children: [
//                     pw.Text(
//                       'Bill To:',
//                       style: pw.TextStyle(
//                         fontSize: 10,
//                         color: PdfColors.grey600,
//                       ),
//                     ),
//                     pw.SizedBox(height: 4),
//                     pw.Text(
//                       invoice.guestName,
//                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                     ),
//                     pw.Text(invoice.guestEmail),
//                     pw.Text(invoice.guestPhone),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//
//           // Booking Details
//           pw.Container(
//             padding: const pw.EdgeInsets.all(12),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.grey100,
//               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//             ),
//             child: pw.Row(
//               children: [
//                 pw.Expanded(
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'Booking: ${invoice.bookingNumber}',
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                       pw.Text('Room: ${invoice.roomNumber}'),
//                     ],
//                   ),
//                 ),
//                 pw.Expanded(
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text(
//                         'Check-in: ${invoice.checkInDate.day}/${invoice.checkInDate.month}/${invoice.checkInDate.year}',
//                       ),
//                       pw.Text(
//                         'Check-out: ${invoice.checkOutDate.day}/${invoice.checkOutDate.month}/${invoice.checkOutDate.year}',
//                       ),
//                       pw.Text('${invoice.numberOfNights} nights'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 20),
//
//           // Charges Table
//           pw.Text(
//             'Charges',
//             style: pw.TextStyle(
//               fontSize: 16,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             decoration: pw.BoxDecoration(
//               border: pw.Border.all(color: PdfColors.grey300),
//               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//             ),
//             child: pw.Column(
//               children: [
//                 _buildChargeRow(
//                   'Room Charges',
//                   invoice.roomCharges,
//                   isHeader: true,
//                 ),
//                 if (invoice.foodCharges > 0)
//                   _buildChargeRow(
//                     'Food & Beverage',
//                     invoice.foodCharges,
//                   ),
//                 if (invoice.serviceCharges > 0)
//                   _buildChargeRow(
//                     'Service Charges',
//                     invoice.serviceCharges,
//                   ),
//                 if (invoice.taxAmount > 0)
//                   _buildChargeRow(
//                     invoice.taxDescription ?? 'Tax',
//                     invoice.taxAmount,
//                   ),
//                 if (invoice.discountAmount > 0)
//                   _buildChargeRow(
//                     'Discount',
//                     -invoice.discountAmount,
//                   ),
//                 pw.Divider(),
//                 _buildChargeRow(
//                   'Total',
//                   invoice.totalAmount,
//                   isTotal: true,
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 16),
//
//           // Payment Summary
//           pw.Container(
//             padding: const pw.EdgeInsets.all(12),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.blue50,
//               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
//             ),
//             child: pw.Column(
//               children: [
//                 _buildPaymentRow(
//                   'Paid Amount',
//                   invoice.paidAmount,
//                 ),
//                 _buildPaymentRow(
//                   'Due Amount',
//                   invoice.dueAmount,
//                   isDue: true,
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 16),
//
//           // Notes
//           if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
//             pw.Text(
//               'Notes:',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 4),
//             pw.Text(invoice.notes!),
//             pw.SizedBox(height: 16),
//           ],
//
//           // Terms
//           if (invoice.termsAndConditions != null &&
//               invoice.termsAndConditions!.isNotEmpty) ...[
//             pw.Text(
//               'Terms & Conditions:',
//               style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 4),
//             pw.Text(
//               invoice.termsAndConditions!,
//               style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
//             ),
//           ],
//
//           // Footer
//           pw.SizedBox(height: 20),
//           pw.Center(
//             child: pw.Text(
//               'Thank you for your stay!',
//               style: pw.TextStyle(
//                 fontSize: 16,
//                 fontWeight: pw.FontWeight.bold,
//                 color: PdfColors.blue800,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 8),
//           pw.Center(
//             child: pw.Text(
//               'Generated on: ${invoice.createdAt.day}/${invoice.createdAt.month}/${invoice.createdAt.year}',
//               style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     return pdf.save();
//   }
//
//   static pw.Widget _buildChargeRow(String label, double amount,
//       {bool isHeader = false, bool isTotal = false}) {
//     return pw.Container(
//       padding: pw.EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: isHeader ? 12 : 8,
//       ),
//       decoration: pw.BoxDecoration(
//         color: isHeader ? PdfColors.grey200 : null,
//       ),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               fontWeight: isHeader || isTotal
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//             ),
//           ),
//           pw.Text(
//             CurrencyFormatter.format(amount),
//             style: pw.TextStyle(
//               fontWeight: isHeader || isTotal
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//               color: isTotal ? PdfColors.blue800 : null,
//               fontSize: isTotal ? 16 : 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildPaymentRow(String label, double amount,
//       {bool isDue = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label),
//           pw.Text(
//             CurrencyFormatter.format(amount),
//             style: pw.TextStyle(
//               fontWeight: pw.FontWeight.bold,
//               color: isDue
//                   ? (amount > 0 ? PdfColors.red : PdfColors.green)
//                   : PdfColors.green,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static PdfColor _getStatusColor(String status) {
//     switch (status) {
//       case 'PAID':
//         return PdfColor.fromInt(0xFF4CAF50); // Green
//       case 'SENT':
//         return PdfColor.fromInt(0xFF2196F3); // Blue
//       case 'DRAFT':
//         return PdfColor.fromInt(0xFF9E9E9E); // Grey
//       case 'OVERDUE':
//         return PdfColor.fromInt(0xFFF44336); // Red
//       case 'CANCELLED':
//         return PdfColor.fromInt(0xFFFF9800); // Orange
//       default:
//         return PdfColor.fromInt(0xFF9E9E9E); // Grey
//     }
//   }
// }
//
