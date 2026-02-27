import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../data/entity/expense.dart';
import '../data/entity/session.dart';
import '../data/entity/cat.dart';
import '../data/entity/hotel_entities.dart';
import '../data/entity/deposit_entities.dart';
import '../data/model/hotel_models.dart';
import 'dart:convert';
import '../util/image_utils.dart';

class PdfGenerator {
  static const _primaryColor = PdfColors.orange;
  static const _pageFormat = PdfPageFormat.a4;

  /// Load logo image from Base64 string
  static pw.MemoryImage? _loadLogoImage(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) return null;
    
    if (ImageUtils.isBase64Image(logoPath)) {
      try {
        final bytes = base64Decode(logoPath);
        return pw.MemoryImage(bytes);
      } catch (e) {
        debugPrint("PDF Gen: Error decoding Base64 logo: $e");
      }
    }
    
    return null;
  }

  static Future<void> printHotelInvoice({
    required BillingGroup group,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
    double depositDeducted = 0.0,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    // Prepare logo image if exists
    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              if (userPlan == "starter") _buildWatermark(width: _pageFormat.width, height: _pageFormat.height, font: boldFont),
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "HOTEL INVOICE",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          final sdf = DateFormat('dd MMM yyyy');
          final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final minCheckIn = group.bookings.map((b) => b.checkInDate).reduce((a, b) => a < b ? a : b);
          final maxCheckOut = group.bookings.map((b) => b.checkOutDate > 0 ? b.checkOutDate : DateTime.now().millisecondsSinceEpoch).reduce((a, b) => a > b ? a : b);

          final items = <pw.Widget>[];

          // === DATA TAMU (left) + WAKTU MENGINAP (right) ===
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('DATA TAMU', _primaryColor, boldFont, padding: 0),
                          _buildInfoRow('Pemilik', group.ownerName, font, padding: 0),
                          _buildInfoRow('No. HP', group.ownerPhone, font, padding: 0),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildSectionTitle('WAKTU MENGINAP', _primaryColor, boldFont, padding: 0),
                          pw.Text('Mulai: ${sdf.format(DateTime.fromMillisecondsSinceEpoch(minCheckIn))}',
                              style: pw.TextStyle(font: font, fontSize: 14)),
                          pw.Text('Selesai: ${sdf.format(DateTime.fromMillisecondsSinceEpoch(maxCheckOut))}',
                              style: pw.TextStyle(font: font, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ));

          // === RINCIAN BIAYA (outside the box) ===
          items.add(_buildSectionTitle('RINCIAN BIAYA', _primaryColor, boldFont));

          // === Per-cat details ===
          for (int i = 0; i < group.bookings.length; i++) {
            final booking = group.bookings[i];
            final room = group.rooms[i];
            final cat = group.cats[i];
            final checkIn = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate);
            final checkOut = DateTime.fromMillisecondsSinceEpoch(
                booking.checkOutDate > 0 ? booking.checkOutDate : DateTime.now().millisecondsSinceEpoch);
            final days = checkOut.difference(checkIn).inDays;
            final actualDays = days < 1 ? 1 : days;
            final roomTotal = actualDays * room.pricePerNight;

            items.add(pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 8),

                  // Cat header
                  pw.Text('Tamu: ${cat.catName} - ${room.name}',
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                  pw.SizedBox(height: 4),

                  // Table header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Item', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      pw.Text('Total', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                    ],
                  ),
                  pw.Divider(color: PdfColors.grey400),

                  // Room cost
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('Sewa Kamar (${room.name}) - $actualDays Malam',
                          style: pw.TextStyle(font: font, fontSize: 13))),
                      pw.SizedBox(width: 8),
                      pw.Text(currencyFmt.format(roomTotal), style: pw.TextStyle(font: font, fontSize: 13)),
                    ],
                  ),

                  // Subtotal setup
                  ...(() {
                    double subTotal = roomTotal.toDouble();
                    final widgets = <pw.Widget>[];

                    // Add-ons for this booking
                    final bookingAddOns = group.addOns.where((a) => a.bookingId == booking.id).toList();
                    for (final addon in bookingAddOns) {
                      final itemTotal = addon.price * addon.qty;
                      subTotal += itemTotal;
                      widgets.add(pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text('${addon.itemName} (${addon.qty}x)',
                              style: pw.TextStyle(font: font, fontSize: 13))),
                          pw.SizedBox(width: 8),
                          pw.Text(currencyFmt.format(itemTotal), style: pw.TextStyle(font: font, fontSize: 13)),
                        ],
                      ));
                    }

                    // Booking notes
                    if (booking.notes.isNotEmpty) {
                      widgets.add(pw.SizedBox(height: 4));
                      widgets.add(pw.Text('Catatan: ${booking.notes}',
                          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)));
                    }

                    // Subtotal per cat
                    widgets.add(pw.Divider(color: PdfColors.black));
                    widgets.add(pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text('SUBTOTAL',
                            style: pw.TextStyle(font: boldFont, fontSize: 14, color: _primaryColor))),
                        pw.SizedBox(width: 8),
                        pw.Text(currencyFmt.format(subTotal),
                            style: pw.TextStyle(font: boldFont, fontSize: 14, color: _primaryColor)),
                      ],
                    ));

                    return widgets;
                  }()),

                  // Separator between cats
                  if (i < group.bookings.length - 1) ...[
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.grey300),
                  ],
                ],
              ),
            ));
          }

          items.add(pw.SizedBox(height: 20));

          // === TOTAL TAGIHAN BOX ===
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _primaryColor, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('TOTAL TAGIHAN',
                      style: pw.TextStyle(font: boldFont, fontSize: 18, color: _primaryColor))),
                  pw.SizedBox(width: 8),
                  pw.Text(currencyFmt.format(group.totalCost),
                      style: pw.TextStyle(font: boldFont, fontSize: 26, color: _primaryColor)),
                ],
              ),
            ),
          ));

          final remaining = group.remaining;
          final balanceLabel = remaining >= 0 ? 'SISA TAGIHAN' : 'KEMBALIAN';
          final balanceValue = remaining >= 0 ? remaining : -remaining;
          final balanceColor = remaining >= 0 ? PdfColors.red : const PdfColor.fromInt(0xFF4CAF50);

          // DP Row and Balance Breakdown
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('Down Payment (DP)', style: pw.TextStyle(font: font, fontSize: 14))),
                    pw.SizedBox(width: 8),
                    pw.Text(currencyFmt.format(group.totalDp), style: pw.TextStyle(font: font, fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.black),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(balanceLabel,
                        style: pw.TextStyle(font: boldFont, fontSize: 18, color: balanceColor))),
                    pw.SizedBox(width: 8),
                    pw.Text(currencyFmt.format(balanceValue),
                        style: pw.TextStyle(font: boldFont, fontSize: 22, color: balanceColor)),
                  ],
                ),
              ],
            ),
          ));

          if (depositDeducted > 0) {
            items.addAll(_buildDepositDeductionSection(
              totalBeforeDeposit: balanceValue,
              depositDeducted: depositDeducted,
              font: font,
              boldFont: boldFont,
              currencyFmt: currencyFmt,
            ));
          }

          return items;
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _handleShare(bytes, "Invoice_Hotel_${group.ownerName}_$ts");
  }

  static Future<void> printHotelDpInvoice({
    required BillingGroup group,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              if (userPlan == "starter") _buildWatermark(width: _pageFormat.width, height: _pageFormat.height, font: boldFont),
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "BUKTI DOWN PAYMENT",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          final sdf = DateFormat('dd MMM yyyy');
          final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final firstCat = group.cats.isNotEmpty ? group.cats.first : null;
          final firstBooking = group.bookings.isNotEmpty ? group.bookings.first : null;
          final firstRoom = group.rooms.isNotEmpty ? group.rooms.first : null;

          return [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Tanggal Cetak
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 150, child: pw.Text('Tanggal Cetak:', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.Expanded(child: pw.Text(sdf.format(DateTime.now()), style: pw.TextStyle(font: boldFont, fontSize: 14))),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 8),

                  // Pemilik
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 150, child: pw.Text('Pemilik:', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.Expanded(child: pw.Text(group.ownerName, style: pw.TextStyle(font: boldFont, fontSize: 14))),
                    ],
                  ),
                  pw.SizedBox(height: 4),

                  // Hewan
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 150, child: pw.Text('Hewan:', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.Expanded(child: pw.Text(
                          '${firstCat?.catName ?? "-"} (${firstCat?.breed ?? "-"})',
                          style: pw.TextStyle(font: boldFont, fontSize: 14))),
                    ],
                  ),
                  pw.SizedBox(height: 4),

                  // Kamar
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 150, child: pw.Text('Kamar:', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.Expanded(child: pw.Text(firstRoom?.name ?? '-', style: pw.TextStyle(font: boldFont, fontSize: 14))),
                    ],
                  ),
                  pw.SizedBox(height: 4),

                  // Periode
                  pw.Row(
                    children: [
                      pw.SizedBox(width: 150, child: pw.Text('Periode:', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.Expanded(child: pw.Text(
                          firstBooking != null
                              ? '${sdf.format(DateTime.fromMillisecondsSinceEpoch(firstBooking.checkInDate))} - ${sdf.format(DateTime.fromMillisecondsSinceEpoch(firstBooking.checkOutDate))}'
                              : '-',
                          style: pw.TextStyle(font: boldFont, fontSize: 14))),
                    ],
                  ),

                  pw.SizedBox(height: 16),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 20),

                  // === TOTAL DP DITERIMA BOX (centered like Kotlin) ===
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _primaryColor, width: 2),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('TOTAL DP DITERIMA',
                            style: pw.TextStyle(font: boldFont, fontSize: 18, color: _primaryColor)),
                        pw.SizedBox(height: 8),
                        pw.Text(currencyFmt.format(group.totalDp),
                            style: pw.TextStyle(font: boldFont, fontSize: 30, color: _primaryColor)),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text('Terima Kasih atas kepercayaan Anda.',
                        style: pw.TextStyle(font: italicFont, fontSize: 13, color: PdfColors.grey600)),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _handleShare(bytes, "Invoice_DP_${group.ownerName}_$ts");
  }

  static Future<void> printFinancialReport({
    required DateTime month,
    required double income,
    required double expense,
    required List<Expense> expenses,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              // Logo Watermark
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "LAPORAN KEUANGAN",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Periode: ${DateFormat('MMMM yyyy', 'id_ID').format(month)}',
                      style: pw.TextStyle(font: boldFont, fontSize: 18)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildReportSummaryItem('Pemasukan', income, PdfColors.green, font, boldFont),
                        _buildReportSummaryItem('Pengeluaran', expense, PdfColors.red, font, boldFont),
                        _buildReportSummaryItem('Profit', income - expense, PdfColors.blue, font, boldFont),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _buildSectionTitle('RINCIAN PENGELUARAN', _primaryColor, boldFont, padding: 0),
                  pw.TableHelper.fromTextArray(
                    context: context,
                    border: pw.TableBorder.all(color: PdfColors.grey300),
                    headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: _primaryColor),
                    cellStyle: pw.TextStyle(font: font, fontSize: 12),
                    headers: ['Tanggal', 'Keterangan', 'Jumlah'],
                    data: expenses
                        .map((e) => [
                              DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(e.date)),
                              e.note,
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(e.amount),
                            ])
                        .toList(),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await _handleShare(bytes, 'Laporan_${DateFormat('MMM_yyyy').format(month)}');
  }

  static Future<void> printSessionInvoice({
    required Session session,
    required Cat cat,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
    Map<String, int>? servicePrices,
    double depositDeducted = 0.0,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              if (userPlan == "starter") _buildWatermark(width: _pageFormat.width, height: _pageFormat.height, font: boldFont),
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "GROOMING INVOICE",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // === DATA HEWAN (left) + DATA PEMILIK (right) ===
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('DATA HEWAN', _primaryColor, boldFont, padding: 0),
                          _buildInfoRow('Nama', cat.catName, font, padding: 0),
                          _buildInfoRow('Ras', cat.breed, font, padding: 0),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildSectionTitle('DATA PEMILIK', _primaryColor, boldFont, padding: 0),
                          pw.Text('Pemilik: ${cat.ownerName}', style: pw.TextStyle(font: font, fontSize: 14)),
                          pw.Text(
                              'Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(session.timestamp))}',
                               style: pw.TextStyle(font: font, fontSize: 14)),
                         ],
                       ),
                    ],
                  ),

                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 12),

                  // === FINDINGS (TEMUAN) — RED BULLETS (shown first like Kotlin) ===
                  _buildSectionTitle('FINDINGS (TEMUAN)', PdfColors.red, boldFont, padding: 0),
                  if (session.findings.isEmpty)
                    pw.Text('- Tidak ada data', style: pw.TextStyle(font: font, fontSize: 13)),
                  ...session.findings.map((f) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 8, height: 8,
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.red,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Expanded(child: pw.Text(f, style: pw.TextStyle(font: font, fontSize: 13))),
                      ],
                    ),
                  )),

                  pw.SizedBox(height: 16),

                  // === TREATMENT (PERAWATAN) — GREEN BULLETS ===
                  _buildSectionTitle('TREATMENT (PERAWATAN)', const PdfColor.fromInt(0xFF006400), boldFont, padding: 0),
                  if (session.treatment.isEmpty)
                    pw.Text('- Tidak ada data', style: pw.TextStyle(font: font, fontSize: 13)),
                  ...session.treatment.map((t) {
                    final price = servicePrices?[t];
                    final priceString = price != null
                        ? NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price)
                        : '';
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 8, height: 8,
                                  decoration: const pw.BoxDecoration(
                                    color: PdfColor.fromInt(0xFF006400),
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.SizedBox(width: 8),
                                pw.Expanded(child: pw.Text(t, style: pw.TextStyle(font: font, fontSize: 13))),
                              ],
                            ),
                          ),
                          if (priceString.isNotEmpty) ...[
                            pw.SizedBox(width: 8),
                            pw.Text(priceString, style: pw.TextStyle(font: font, fontSize: 13)),
                          ],
                        ],
                      ),
                    );
                  }),

                  pw.SizedBox(height: 16),

                  // === Catatan Groomer ===
                  pw.Text('Catatan Groomer:', style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.grey800)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    session.groomerNotes.isNotEmpty ? session.groomerNotes : '-',
                    style: pw.TextStyle(font: font, fontSize: 13, color: session.groomerNotes.isNotEmpty ? PdfColors.black : PdfColors.grey),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // === TOTAL BIAYA BOX (orange border like Kotlin) ===
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _primaryColor, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text('TOTAL BIAYA',
                        style: pw.TextStyle(font: boldFont, fontSize: 18, color: _primaryColor))),
                    pw.SizedBox(width: 8),
                    pw.Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 2).format(session.totalCost),
                        style: pw.TextStyle(font: boldFont, fontSize: 26, color: _primaryColor)),
                  ],
                ),
              ),
            ),

            if (depositDeducted > 0)
              ..._buildDepositDeductionSection(
                totalBeforeDeposit: session.totalCost.toDouble(),
                depositDeducted: depositDeducted,
                font: font,
                boldFont: boldFont,
                currencyFmt: NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0),
              ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _handleShare(bytes, "Invoice_${cat.catName}_${session.sessionId}_$ts");
  }

  /// Combined invoice for multiple grooming sessions
  static Future<void> printCombinedSessionInvoice({
    required List<Session> sessions,
    required List<Cat> cats,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
    double depositDeducted = 0.0,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    final grandTotal = sessions.fold(0.0, (sum, s) => sum + s.totalCost);

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              if (userPlan == "starter") _buildWatermark(width: _pageFormat.width, height: _pageFormat.height, font: boldFont),
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "INVOICE GABUNGAN GROOMING",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final sdf = DateFormat('dd MMM yyyy');
          final items = <pw.Widget>[];

          // === DATA CUSTOMER ===
          final firstCatId = sessions.first.catId;
          final matchedCat = cats.where((c) => c.catId == firstCatId).firstOrNull;
          final ownerName = matchedCat?.ownerName ?? (cats.isNotEmpty ? cats.first.ownerName : '');
          final ownerPhone = matchedCat?.ownerPhone ?? (cats.isNotEmpty ? cats.first.ownerPhone : '');

          items.add(_buildSectionTitle('DATA CUSTOMER', _primaryColor, boldFont));
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Pemilik: $ownerName', style: pw.TextStyle(font: font, fontSize: 14)),
                    pw.Text('HP: $ownerPhone', style: pw.TextStyle(font: font, fontSize: 14)),
                  ],
                ),
                pw.Text('Tanggal Cetak: ${sdf.format(DateTime.now())}',
                    style: pw.TextStyle(font: font, fontSize: 14)),
              ],
            ),
          ));
          items.add(pw.SizedBox(height: 8));
          items.add(pw.Divider(color: PdfColors.grey300));
          items.add(pw.SizedBox(height: 12));

          // === RINCIAN LAYANAN ===
          items.add(_buildSectionTitle('RINCIAN LAYANAN', _primaryColor, boldFont));
          items.add(pw.SizedBox(height: 8));

          for (int i = 0; i < sessions.length; i++) {
            final session = sessions[i];
            final cat = cats.where((c) => c.catId == session.catId).firstOrNull;
            final catName = cat?.catName ?? 'Unknown';

            final treatments = session.treatment.isNotEmpty ? session.treatment.join(', ') : '-';
            final findingsList = session.findings.where((f) => f.isNotEmpty).toList();

            items.add(pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Cat name
                  pw.Text('${i + 1}. $catName',
                      style: pw.TextStyle(font: boldFont, fontSize: 14)),
                  pw.SizedBox(height: 4),

                  // Paket (treatments)
                  pw.Text('Paket: $treatments',
                      style: pw.TextStyle(font: font, fontSize: 13)),

                  // Temuan (findings) in red
                  if (findingsList.isNotEmpty)
                    pw.Text('Temuan: ${findingsList.join(", ")}',
                        style: pw.TextStyle(font: font, fontSize: 13, color: PdfColors.red)),

                  // Catatan (groomer notes) in dark gray
                  if (session.groomerNotes.isNotEmpty)
                    pw.Text('Catatan: ${session.groomerNotes}',
                        style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),

                  // Price right-aligned
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(currencyFmt.format(session.totalCost),
                        style: pw.TextStyle(font: boldFont, fontSize: 14, color: _primaryColor)),
                  ),

                  // Separator
                  pw.SizedBox(height: 8),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                ],
              ),
            ));
          }

          // === GRAND TOTAL BOX ===
          items.add(pw.SizedBox(height: 12));
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _primaryColor, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('GRAND TOTAL',
                      style: pw.TextStyle(font: boldFont, fontSize: 18, color: _primaryColor))),
                  pw.SizedBox(width: 8),
                  pw.Text(currencyFmt.format(grandTotal),
                      style: pw.TextStyle(font: boldFont, fontSize: 26, color: _primaryColor)),
                ],
              ),
            ),
          ));

          if (depositDeducted > 0) {
            items.addAll(_buildDepositDeductionSection(
              totalBeforeDeposit: grandTotal.toDouble(),
              depositDeducted: depositDeducted,
              font: font,
              boldFont: boldFont,
              currencyFmt: currencyFmt,
            ));
          }

          return items;
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final ownerLabel = sessions.isNotEmpty
        ? (cats.where((c) => c.catId == sessions.first.catId).firstOrNull?.ownerName ?? 'Unknown')
        : 'Unknown';
    await _handleShare(bytes, "Invoice_Gabungan_Grooming_${ownerLabel}_$ts");
  }

  /// Combined invoice for mixed grooming + hotel transactions
  static Future<void> printCombinedMixedInvoice({
    required List<Session> sessions,
    required List<HotelBooking> hotelBookings,
    required List<Cat> cats,
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    String? logoPath,
    String userPlan = "pro",
    List<HotelAddOn> hotelAddOns = const [],
    List<HotelRoom> hotelRooms = const [],
    double hotelTotalDp = 0.0,
    double depositDeducted = 0.0,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    final groomingTotal = sessions.fold(0.0, (sum, s) => sum + s.totalCost);
    final hotelTotal = hotelBookings.fold(0.0, (sum, b) => sum + b.totalCost);
    final grandTotal = groomingTotal + hotelTotal;

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: _pageFormat,
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont, italic: italicFont),
          buildBackground: (pw.Context context) => pw.Stack(
            children: [
              pw.Container(color: PdfColors.white),
              if (userPlan == "starter") _buildWatermark(width: _pageFormat.width, height: _pageFormat.height, font: boldFont),
              if (logoImage != null)
                pw.Center(
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Image(logoImage, width: 240),
                  ),
                ),
            ],
          ),
        ),
        header: (pw.Context context) => _buildHeader(
          businessName: businessName,
          businessPhone: businessPhone,
          businessAddress: businessAddress,
          title: "INVOICE GABUNGAN",
          font: font,
          boldFont: boldFont,
        ),
        footer: (pw.Context context) => _buildFooter(italicFont),
        build: (pw.Context context) {
          final items = <pw.Widget>[];
          final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          final sdf = DateFormat('dd MMM yyyy');

          // === DATA PELANGGAN ===
          // Resolve owner from the first available session or hotel booking
          Cat? matchedCat;
          if (sessions.isNotEmpty) {
            matchedCat = cats.where((c) => c.catId == sessions.first.catId).firstOrNull;
          } else if (hotelBookings.isNotEmpty) {
            matchedCat = cats.where((c) => c.catId == hotelBookings.first.catId).firstOrNull;
          }
          final ownerName = matchedCat?.ownerName ?? (cats.isNotEmpty ? cats.first.ownerName : '');
          final ownerPhone = matchedCat?.ownerPhone ?? (cats.isNotEmpty ? cats.first.ownerPhone : '');

          items.add(_buildSectionTitle('DATA PELANGGAN', _primaryColor, boldFont));
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Nama: $ownerName', style: pw.TextStyle(font: font, fontSize: 14)),
                    pw.Text('No. HP: $ownerPhone', style: pw.TextStyle(font: font, fontSize: 14)),
                  ],
                ),
                pw.Text('Tanggal: ${sdf.format(DateTime.now())}',
                    style: pw.TextStyle(font: font, fontSize: 14)),
              ],
            ),
          ));
          items.add(pw.SizedBox(height: 8));
          items.add(pw.Divider(color: PdfColors.grey300));
          items.add(pw.SizedBox(height: 12));

          // === LAYANAN GROOMING SECTION ===
          if (sessions.isNotEmpty) {
            items.add(_buildSectionTitle('LAYANAN GROOMING', _primaryColor, boldFont));
            items.add(pw.SizedBox(height: 8));

            for (int i = 0; i < sessions.length; i++) {
              final session = sessions[i];
              final cat = cats.where((c) => c.catId == session.catId).firstOrNull;
              final catName = cat?.catName ?? 'Unknown';

              final treatments = session.treatment.isNotEmpty ? session.treatment.join(', ') : '-';
              final findingsList = session.findings.where((f) => f.isNotEmpty).toList();

              items.add(pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Cat name with (Grooming) suffix
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text('${i + 1}. $catName (Grooming)',
                            style: pw.TextStyle(font: boldFont, fontSize: 14))),
                        pw.SizedBox(width: 8),
                        pw.Text(currencyFmt.format(session.totalCost),
                            style: pw.TextStyle(font: boldFont, fontSize: 14)),
                      ],
                    ),

                    // Paket (treatments)
                    pw.Text('Paket: $treatments',
                        style: pw.TextStyle(font: font, fontSize: 13)),

                    // Temuan (findings) in red
                    if (findingsList.isNotEmpty)
                      pw.Text('Temuan: ${findingsList.join(", ")}',
                          style: pw.TextStyle(font: font, fontSize: 13, color: PdfColors.red)),

                    // Catatan (groomer notes) in dark gray
                    if (session.groomerNotes.isNotEmpty)
                      pw.Text('Catatan: ${session.groomerNotes}',
                          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),

                    // Separator
                    pw.SizedBox(height: 8),
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ));
            }
            items.add(pw.SizedBox(height: 8));
          }

          // === LAYANAN HOTEL SECTION ===
          if (hotelBookings.isNotEmpty) {
            items.add(_buildSectionTitle('LAYANAN HOTEL', _primaryColor, boldFont));
            items.add(pw.SizedBox(height: 8));

            for (int i = 0; i < hotelBookings.length; i++) {
              final booking = hotelBookings[i];
              final cat = cats.where((c) => c.catId == booking.catId).firstOrNull;
              final catName = cat?.catName ?? 'Unknown';
              final room = hotelRooms.isNotEmpty
                  ? hotelRooms.firstWhere((r) => r.id == booking.roomId, orElse: () => HotelRoom(name: 'Unknown'))
                  : null;
              final roomName = room?.name ?? 'Kamar';
              final checkIn = DateTime.fromMillisecondsSinceEpoch(booking.checkInDate);
              final checkOut = DateTime.fromMillisecondsSinceEpoch(
                  booking.checkOutDate > 0 ? booking.checkOutDate : DateTime.now().millisecondsSinceEpoch);
              final days = checkOut.difference(checkIn).inDays;
              final actualDays = days < 1 ? 1 : days;

              // Get add-ons for this booking
              final bookingAddOns = hotelAddOns.where((a) => a.bookingId == booking.id).toList();

              items.add(pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Cat name with (Hotel) suffix
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text('${i + 1}. $catName (Hotel)',
                            style: pw.TextStyle(font: boldFont, fontSize: 14))),
                        pw.SizedBox(width: 8),
                        pw.Text(currencyFmt.format(booking.totalCost),
                            style: pw.TextStyle(font: boldFont, fontSize: 14)),
                      ],
                    ),

                    // Duration with room name
                    pw.Text('Sewa $roomName ($actualDays hari)',
                        style: pw.TextStyle(font: font, fontSize: 13)),

                    // Add-ons
                    ...bookingAddOns.map((addon) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text('  + ${addon.itemName} (${addon.qty}x)',
                            style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700))),
                        pw.SizedBox(width: 8),
                        pw.Text(currencyFmt.format(addon.price * addon.qty),
                            style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
                      ],
                    )),

                    // Catatan
                    if (booking.notes.isNotEmpty)
                      pw.Text('Catatan: ${booking.notes}',
                          style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),

                    // Separator
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ));
            }
          }

          // === SUBTOTALS ===
          if (sessions.isNotEmpty && hotelBookings.isNotEmpty) {
            items.add(pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal Grooming', style: pw.TextStyle(font: font, fontSize: 13)),
                      pw.Text(currencyFmt.format(groomingTotal), style: pw.TextStyle(font: font, fontSize: 13)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subtotal Hotel', style: pw.TextStyle(font: font, fontSize: 13)),
                      pw.Text(currencyFmt.format(hotelTotal), style: pw.TextStyle(font: font, fontSize: 13)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                ],
              ),
            ));
          }

          // === GRAND TOTAL BOX ===
          items.add(pw.SizedBox(height: 12));
          items.add(pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _primaryColor, width: 2),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('GRAND TOTAL',
                      style: pw.TextStyle(font: boldFont, fontSize: 18, color: _primaryColor))),
                  pw.SizedBox(width: 8),
                  pw.Text(currencyFmt.format(grandTotal),
                      style: pw.TextStyle(font: boldFont, fontSize: 26, color: _primaryColor)),
                ],
              ),
            ),
          ));

          // === DP & REMAINING (only if hotel has DP) ===
          if (hotelTotalDp > 0) {
            final remaining = grandTotal - hotelTotalDp;
            final balanceLabel = remaining >= 0 ? 'SISA TAGIHAN' : 'KEMBALIAN';
            final balanceValue = remaining >= 0 ? remaining : -remaining;
            final balanceColor = remaining >= 0 ? PdfColors.red : const PdfColor.fromInt(0xFF4CAF50);

            items.add(pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 40),
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('Down Payment (DP)', style: pw.TextStyle(font: font, fontSize: 14))),
                      pw.SizedBox(width: 8),
                      pw.Text('- ${currencyFmt.format(hotelTotalDp)}', style: pw.TextStyle(font: font, fontSize: 14)),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(color: PdfColors.black),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(balanceLabel,
                          style: pw.TextStyle(font: boldFont, fontSize: 18, color: balanceColor))),
                      pw.SizedBox(width: 8),
                      pw.Text(currencyFmt.format(balanceValue),
                          style: pw.TextStyle(font: boldFont, fontSize: 22, color: balanceColor)),
                    ],
                  ),
                ],
              ),
            ));
          }

          // After DP section, add deposit deduction if applicable
          final effectiveTotal = hotelTotalDp > 0 ? (grandTotal - hotelTotalDp) : grandTotal;
          if (depositDeducted > 0) {
            items.addAll(_buildDepositDeductionSection(
              totalBeforeDeposit: effectiveTotal,
              depositDeducted: depositDeducted,
              font: font,
              boldFont: boldFont,
              currencyFmt: currencyFmt,
            ));
          }

          return items;
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    Cat? firstOwnerCat;
    if (sessions.isNotEmpty) {
      firstOwnerCat = cats.where((c) => c.catId == sessions.first.catId).firstOrNull;
    } else if (hotelBookings.isNotEmpty) {
      firstOwnerCat = cats.where((c) => c.catId == hotelBookings.first.catId).firstOrNull;
    }
    final ownerLabel = firstOwnerCat?.ownerName ?? 'Unknown';
    await _handleShare(bytes, "Invoice_Gabungan_${ownerLabel}_$ts");
  }

  // ─── DEPOSIT DOCUMENTS ─────────────────────────────────────────────────

  /// Print a single deposit top-up receipt
  static Future<void> printDepositReceipt({
    required DepositTransaction transaction,
    required String ownerName,
    required double currentBalance,
    String? businessName,
    String? logoPath,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();
    final sdf = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.Page(
        pageTheme: _buildPageTheme(font, boldFont, italicFont),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              if (businessName != null)
                pw.Center(child: pw.Text(businessName, style: pw.TextStyle(font: boldFont, fontSize: 20, color: _primaryColor))),
              pw.SizedBox(height: 4),
              pw.Center(child: pw.Text('BUKTI TOP UP DEPOSIT', style: pw.TextStyle(font: boldFont, fontSize: 16, color: _primaryColor))),
              pw.Divider(color: _primaryColor, thickness: 2),
              pw.SizedBox(height: 16),

              // Info
              _buildInfoRow('Nama', ownerName, font, padding: 0),
              _buildInfoRow('Tanggal', sdf.format(DateTime.fromMillisecondsSinceEpoch(transaction.timestamp)), font, padding: 0),
              _buildInfoRow('Jenis', _txnTypeLabel(transaction.type), font, padding: 0),
              if (transaction.notes.isNotEmpty)
                _buildInfoRow('Catatan', transaction.notes, font, padding: 0),
              pw.SizedBox(height: 20),

              // Amount box
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFF4CAF50), width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('JUMLAH TOP UP', style: pw.TextStyle(font: boldFont, fontSize: 16, color: const PdfColor.fromInt(0xFF4CAF50))),
                    pw.Text(currencyFmt.format(transaction.amount),
                        style: pw.TextStyle(font: boldFont, fontSize: 22, color: const PdfColor.fromInt(0xFF4CAF50))),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              _buildInfoRow('Saldo Saat Ini', currencyFmt.format(currentBalance), boldFont, padding: 0),
              pw.SizedBox(height: 24),
              _buildFooter(italicFont),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _handleShare(bytes, 'Deposit_Receipt_${ownerName}_$ts');
  }

  /// Print full deposit history (Rekening Koran)
  static Future<void> printDepositHistory({
    required String ownerName,
    required String ownerPhone,
    required double currentBalance,
    required List<DepositTransaction> transactions,
    String? businessName,
    String? logoPath,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();
    final sdf = DateFormat('dd/MM/yy');
    final currencyFmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // pw.MemoryImage? logoImage = _loadLogoImage(logoPath);

    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildPageTheme(font, boldFont, italicFont),
        footer: (_) => _buildFooter(italicFont),
        build: (ctx) {
          return [
            // Header
            if (businessName != null)
              pw.Center(child: pw.Text(businessName, style: pw.TextStyle(font: boldFont, fontSize: 20, color: _primaryColor))),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text('REKENING KORAN DEPOSIT', style: pw.TextStyle(font: boldFont, fontSize: 16, color: _primaryColor))),
            pw.Divider(color: _primaryColor, thickness: 2),
            pw.SizedBox(height: 12),

            // Owner info
            _buildInfoRow('Nama', ownerName, font, padding: 0),
            _buildInfoRow('No. HP', ownerPhone, font, padding: 0),
            _buildInfoRow('Saldo', currencyFmt.format(currentBalance), boldFont, padding: 0),
            pw.SizedBox(height: 16),

            // Transactions table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _primaryColor),
                  children: [
                    _tableCell('Tanggal', boldFont, color: PdfColors.white),
                    _tableCell('Jenis', boldFont, color: PdfColors.white),
                    _tableCell('Catatan', boldFont, color: PdfColors.white),
                    _tableCell('Jumlah', boldFont, color: PdfColors.white, align: pw.TextAlign.right),
                  ],
                ),
                // Data rows
                ...transactions.map((txn) {
                  final isPlus = txn.amount >= 0;
                  return pw.TableRow(
                    children: [
                      _tableCell(sdf.format(DateTime.fromMillisecondsSinceEpoch(txn.timestamp)), font),
                      _tableCell(_txnTypeLabel(txn.type), font),
                      _tableCell(txn.notes.isNotEmpty ? txn.notes : '-', font),
                      _tableCell(
                        currencyFmt.format(txn.amount),
                        boldFont,
                        color: isPlus ? const PdfColor.fromInt(0xFF4CAF50) : PdfColors.red,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(font: italicFont, fontSize: 10, color: PdfColors.grey500)),
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    final ts = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    await _handleShare(bytes, 'Rekening_Koran_${ownerName}_$ts');
  }

  static String _txnTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.topup: return 'Top Up';
      case TransactionType.groomingPayment: return 'Bayar Grooming';
      case TransactionType.hotelPayment: return 'Bayar Hotel';
      case TransactionType.adjustment: return 'Penyesuaian';
      case TransactionType.refund: return 'Refund';
    }
  }

  static pw.Widget _tableCell(String text, pw.Font font, {PdfColor? color, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 10, color: color ?? PdfColors.black), textAlign: align),
    );
  }

  // --- DEPOSIT DEDUCTION SECTION (reusable) ---

  static List<pw.Widget> _buildDepositDeductionSection({
    required double totalBeforeDeposit,
    required double depositDeducted,
    required pw.Font font,
    required pw.Font boldFont,
    required NumberFormat currencyFmt,
  }) {
    final remaining = totalBeforeDeposit - depositDeducted;
    final remainingLabel = remaining >= 0 ? 'SISA PEMBAYARAN' : 'KEMBALIAN';
    final remainingValue = remaining >= 0 ? remaining : -remaining;
    final remainingColor = remaining > 0 ? PdfColors.red : const PdfColor.fromInt(0xFF4CAF50);

    return [
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 40),
        child: pw.Column(
          children: [
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text('Dibayar dari Deposit', style: pw.TextStyle(font: font, fontSize: 14))),
                pw.SizedBox(width: 8),
                pw.Text('- ${currencyFmt.format(depositDeducted)}',
                    style: pw.TextStyle(font: font, fontSize: 14, color: const PdfColor.fromInt(0xFF4CAF50))),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.black),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(remainingLabel,
                    style: pw.TextStyle(font: boldFont, fontSize: 18, color: remainingColor))),
                pw.SizedBox(width: 8),
                pw.Text(currencyFmt.format(remainingValue),
                    style: pw.TextStyle(font: boldFont, fontSize: 22, color: remainingColor)),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  // --- HELPERS (V2 PARITY) ---

  static pw.Widget _buildHeader({
    required String businessName,
    required String businessPhone,
    String? businessAddress,
    required String title,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    final hasAddress = businessAddress != null && businessAddress.isNotEmpty;
    final isLongAddress = hasAddress && businessAddress.length >= 30;

    return pw.Container(
      width: double.infinity,
      color: _primaryColor,
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: pw.Column(
        children: [
          pw.Text(businessName.toUpperCase(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 30, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          // If address is long, show on separate lines (like Kotlin)
          if (isLongAddress) ...[
            pw.Text(businessAddress,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: PdfColors.white, fontSize: 15)),
            pw.Text(businessPhone,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: PdfColors.white, fontSize: 15)),
          ] else
            pw.Text("${hasAddress ? '$businessAddress • ' : ''}$businessPhone",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(color: PdfColors.white, fontSize: 15)),
          pw.SizedBox(height: 12),
          pw.Text(title,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color, pw.Font font, {double fontSize = 18, double padding = 40}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: 12, bottom: 8, left: padding, right: padding),
      child: pw.Text(
        title,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: color, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, {double padding = 40}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 2, left: padding, right: padding),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label: ', style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
            pw.TextSpan(text: value, style: pw.TextStyle(font: font, fontSize: 15, color: PdfColors.black)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildReportSummaryItem(String label, double value, PdfColor color, pw.Font font, pw.Font bold) {
    return pw.Column(
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.grey700)),
        pw.Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(value),
            style: pw.TextStyle(font: bold, fontSize: 18, color: color)),
      ],
    );
  }

  static pw.Widget _buildWatermark({required double width, required double height, required pw.Font font}) {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.8,
        child: pw.Text(
          'FREE VERSION - UNREGISTERED',
          style: pw.TextStyle(font: font, fontSize: 40, color: const PdfColor.fromInt(0x30808080)),
        ),
      ),
    );
  }

  static pw.PageTheme _buildPageTheme(pw.Font font, pw.Font boldFont, pw.Font italicFont) {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
        italic: italicFont,
      ),
      buildBackground: (context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: PdfColors.white),
        );
      },
    );
  }

  static pw.Widget _buildFooter(pw.Font italicFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Center(
        child: pw.Text('Generated by Cat Grooming Record App',
            style: pw.TextStyle(font: italicFont, fontSize: 12, color: PdfColors.grey500)),
      ),
    );
  }

  static Future<void> _handleShare(Uint8List bytes, String filename) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: '$filename.pdf');
    } catch (e) {
      debugPrint('Share error: $e');
      await Printing.layoutPdf(onLayout: (format) async => bytes, name: filename);
    }
  }
}
