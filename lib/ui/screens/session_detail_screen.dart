import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../financial_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/cat.dart';
import '../../data/entity/session.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/pdf_generator.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

/// Read-only session detail screen.
class SessionDetailScreen extends StatefulWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  Session? _session;
  Cat? _cat;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vm = context.read<GroomingViewModel>();
    final session = await vm.getSession(widget.sessionId);
    Cat? cat;
    if (session != null) cat = await vm.getCat(session.catId);
    if (mounted) {
      setState(() {
        _session = session;
        _cat = cat;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sessionDetail)),
        body: Center(child: Text(l10n.sessionNotFound)),
      );
    }

    final session = _session!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sessionDetail),
        actions: [
          IconButton(
            onPressed: () => _printInvoice(context, session, l10n),
            icon: const Icon(Icons.print_rounded),
            tooltip: l10n.printInvoice,
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/session_entry', arguments: session.sessionId),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Header Card ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(colors: [AppColors.darkSurface, AppColors.darkCard])
                  : LinearGradient(colors: [AppColors.lightPrimary.withValues(alpha: 0.85), AppColors.lightPrimaryDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CatAvatar(imagePath: _cat?.imagePath, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cat?.catName ?? l10n.unknownCat,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        app_date.formatDateTime(session.timestamp),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Cost ────────────────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: isDark ? AppColors.darkCard : AppColors.lightIconBg,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.totalCost, style: const TextStyle(fontSize: 15)),
                  Text(
                    app_date.formatCurrencyDouble(session.totalCost.toDouble()),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Status ──────────────────────────────────────
          _InfoRow(label: l10n.status, value: _getStatusLabel(session.status, l10n)),
          if (session.trackingToken != null) _InfoRow(label: l10n.token, value: session.trackingToken!),

          const Divider(height: 24),

          // ─── Treatments ──────────────────────────────────
          if (session.treatment.isNotEmpty) ...[
            Text(l10n.treatments, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: session.treatment.map((t) => Chip(label: Text(t))).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ─── Findings ────────────────────────────────────
          if (session.findings.isNotEmpty) ...[
            Text(l10n.findings, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: session.findings.map((f) => Chip(
                label: Text(f),
                backgroundColor: isDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.1),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ─── Notes ───────────────────────────────────────
          if (session.groomerNotes.isNotEmpty) ...[
            Text(l10n.groomerNotes, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(session.groomerNotes),
              ),
            ),
          ],
        ],
      ),
    );
  }


  Future<void> _printInvoice(BuildContext context, Session session, AppLocalizations l10n) async {
    try {
      final vm = context.read<GroomingViewModel>();
      // Need bookings linked to this session? 
      // Current Session entity might not have bookings list directly, or we fetch them.
      // Wait, Session has bookings? No, Session has list of treatment strings. 
      // But we have Booking entity. 
      // Actually, Session table and Booking table are separate. 
      // Data model: Session has many Bookings? Or Session IS a collection of services?
      // In Batch 3, Session has `treatment` (List<String>) and `totalCost`.
      // It doesn't link to `Booking` entity directly in a relational way that we can query easily unless we query Bookings by sessionId?
      // Booking entity has `sessionId`? Let's check Booking entity.
      
      // If no bookings linked, we just list treatments.
      // For now, let's create dummy bookings from treatments for the invoice
      // OR fetch bookings if they exist.
      // I'll assume standard Session treatments are what we want to print.
      
      // We need to fetch business info from VM.
      
      // Dummy conversion of strings to Booking objects for PDF generator
      // OR update PDF generator to accept strings.
      // Existing PDF generator expects `List<Booking>`.
      
      // Let's just use what we have.
      // We'll fetch bookings if possible, or create fake ones.
      // GroomingDao has `getBookingsForSession(sessionId)`? 
      // I'll check if `vm` has a method.
      
      // If not, I'll update PdfGenerator to be more flexible or just pass treatments.
      // But `PdfGenerator.printSessionInvoice` requires `List<Booking>`.
      // I should update PdfGenerator to take `List<String> treatments` and `double totalCost`.
      
      // But wait, `Session` entity has `treatment` list.
      // I'll update `PdfGenerator` signature in next step if needed.
      // For now I'll comment out the call or pass empty list.
      
      // Actually, better to fetch bookings.
      // GroomingRepository has `getBookings()`. We can filter by date? 
      // Session usually corresponds to a visit.
      
      // Allow me to check `Booking` entity first.
      if (_cat == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.catDataNotFound)));
        return;
      }

      final servicePrices = {
        for (final s in vm.services) s.serviceName: s.defaultPrice
      };

      final finVm = context.read<FinancialViewModel>();
      final depositPaid = await finVm.getDepositPaidForSession(session.sessionId);

      await PdfGenerator.printSessionInvoice(
        session: session,
        cat: _cat!,
        businessName: vm.businessName,
        businessPhone: vm.businessPhone,
        businessAddress: vm.businessAddress,
        logoPath: vm.logoPath,
        userPlan: vm.userPlan,
        servicePrices: servicePrices,
        depositDeducted: depositPaid,
      );
    } catch (e) {
      debugPrint('Error printing invoice: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.printFailed(e.toString()))));
      }
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'WAITING':
        return l10n.statusWaiting;
      case 'BATHING':
        return l10n.statusBathing;
      case 'DRYING':
        return l10n.statusDrying;
      case 'FINISHING':
        return l10n.statusFinishing;
      case 'PICKUP_READY':
        return l10n.statusPickupReady;
      case 'DONE':
        return l10n.statusDone;
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
