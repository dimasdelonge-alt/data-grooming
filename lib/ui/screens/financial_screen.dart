import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../financial_view_model.dart';
import '../grooming_view_model.dart';
import '../hotel_view_model.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/pdf_generator.dart';
import '../../data/entity/session.dart';
import '../../data/entity/hotel_entities.dart';
import '../../data/entity/cat.dart';
import '../../data/model/hotel_models.dart';
import '../../util/currency_formatter.dart';

class FinancialScreen extends StatefulWidget {
  const FinancialScreen({super.key});

  @override
  State<FinancialScreen> createState() => _FinancialScreenState();
}

class _FinancialScreenState extends State<FinancialScreen> {
  // Multi-select state
  bool _isSelecting = false;
  final Set<String> _selectedKeys = {}; // "session_id" or "hotel_id"
  String? _lockedOwnerName; // Only allow selecting transactions from same owner
  bool _isPrinting = false;

  /// Get owner name for a transaction
  String? _getOwnerOfTxn(dynamic txn) {
    final groomingVm = context.read<GroomingViewModel>();
    int catId;
    if (txn is Session) {
      catId = txn.catId;
    } else if (txn is HotelBooking) {
      catId = txn.catId;
    } else {
      return null;
    }
    final cat = groomingVm.allCats.where((c) => c.catId == catId).firstOrNull;
    return cat?.ownerName;
  }

  void _enterSelection(dynamic txn) {
    final owner = _getOwnerOfTxn(txn);
    setState(() {
      _isSelecting = true;
      _selectedKeys.add(_txnKey(txn));
      _lockedOwnerName = owner;
    });
  }

  void _toggleSelection(dynamic txn) {
    final key = _txnKey(txn);
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
        if (_selectedKeys.isEmpty) {
          _isSelecting = false;
          _lockedOwnerName = null;
        }
      } else {
        // Check same owner
        final owner = _getOwnerOfTxn(txn);
        if (_lockedOwnerName == null || _lockedOwnerName == owner) {
          _selectedKeys.add(key);
          _lockedOwnerName ??= owner;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hanya bisa memilih transaksi dari pemilik yang sama ($_lockedOwnerName)'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelecting = false;
      _selectedKeys.clear();
      _lockedOwnerName = null;
    });
  }

  String _txnKey(dynamic txn) {
    if (txn is Session) return 'session_${txn.sessionId}';
    if (txn is HotelBooking) return 'hotel_${txn.id}';
    return '';
  }

  Future<void> _printSelected(BuildContext context) async {
    if (_selectedKeys.isEmpty || _isPrinting) return;

    setState(() => _isPrinting = true);

    final vm = context.read<FinancialViewModel>();
    final groomingVm = context.read<GroomingViewModel>();
    final transactions = vm.allTransactions;

    final selectedSessions = <Session>[];
    final selectedHotel = <HotelBooking>[];

    for (final txn in transactions) {
      final key = _txnKey(txn);
      if (_selectedKeys.contains(key)) {
        if (txn is Session) selectedSessions.add(txn);
        if (txn is HotelBooking) selectedHotel.add(txn);
      }
    }

    try {
      if (selectedHotel.isEmpty && selectedSessions.isNotEmpty) {
        // Only grooming sessions
        if (selectedSessions.length == 1) {
          final session = selectedSessions.first;
          final cat = groomingVm.allCats.where((c) => c.catId == session.catId).firstOrNull;
          if (cat != null) {
            await PdfGenerator.printSessionInvoice(
              session: session,
              cat: cat,
              businessName: groomingVm.businessName,
              businessPhone: groomingVm.businessPhone,
              businessAddress: groomingVm.businessAddress,
              logoPath: groomingVm.logoPath,
              userPlan: groomingVm.userPlan,
              servicePrices: {
                for (final s in groomingVm.services) s.serviceName: s.defaultPrice
              },
            );
          }
        } else {
          await PdfGenerator.printCombinedSessionInvoice(
            sessions: selectedSessions,
            cats: groomingVm.allCats,
            businessName: groomingVm.businessName,
            businessPhone: groomingVm.businessPhone,
            businessAddress: groomingVm.businessAddress,
            logoPath: groomingVm.logoPath,
            userPlan: groomingVm.userPlan,
          );
        }
      } else if (selectedSessions.isEmpty && selectedHotel.isNotEmpty) {
        // Only hotel bookings — build a proper BillingGroup with add-ons, DP, rooms
        final hotelVm = context.read<HotelViewModel>();
        final cats = groomingVm.allCats;

        final relatedCats = <Cat>[];
        final relatedRooms = <HotelRoom>[];
        final groupAddOns = <HotelAddOn>[];
        double groupTotalCost = 0.0;
        double groupTotalDp = 0.0;

        for (final booking in selectedHotel) {
          final cat = cats.where((c) => c.catId == booking.catId).firstOrNull ?? const Cat(catName: 'Unknown');
          final room = hotelVm.rooms.firstWhere((r) => r.id == booking.roomId, orElse: () => HotelRoom(name: 'Unknown'));
          relatedCats.add(cat);
          relatedRooms.add(room);

          final addons = hotelVm.allAddOns.where((a) => a.bookingId == booking.id).toList();
          groupAddOns.addAll(addons);

          groupTotalCost += booking.totalCost;
          groupTotalDp += booking.dpAmount;
        }

        final totalAddonsCost = groupAddOns.fold(0.0, (sum, a) => sum + (a.price * a.qty));
        final firstCat = relatedCats.isNotEmpty ? relatedCats.first : const Cat(catName: 'Unknown');

        final group = BillingGroup(
          ownerName: firstCat.ownerName,
          ownerPhone: firstCat.ownerPhone,
          bookings: selectedHotel,
          rooms: relatedRooms,
          cats: relatedCats,
          addOns: groupAddOns,
          totalCost: groupTotalCost,
          totalAddOns: totalAddonsCost,
          totalDp: groupTotalDp,
          remaining: groupTotalCost - groupTotalDp,
        );

        await PdfGenerator.printHotelInvoice(
          group: group,
          businessName: groomingVm.businessName,
          businessPhone: groomingVm.businessPhone,
          businessAddress: groomingVm.businessAddress,
          logoPath: groomingVm.logoPath,
          userPlan: groomingVm.userPlan,
        );
      } else {
        // Mixed grooming + hotel
        final hotelVm = context.read<HotelViewModel>();
        final allAddOns = <HotelAddOn>[];
        double totalDp = 0.0;
        for (final booking in selectedHotel) {
          allAddOns.addAll(hotelVm.allAddOns.where((a) => a.bookingId == booking.id));
          totalDp += booking.dpAmount;
        }

        await PdfGenerator.printCombinedMixedInvoice(
          sessions: selectedSessions,
          hotelBookings: selectedHotel,
          cats: groomingVm.allCats,
          businessName: groomingVm.businessName,
          businessPhone: groomingVm.businessPhone,
          businessAddress: groomingVm.businessAddress,
          logoPath: groomingVm.logoPath,
          userPlan: groomingVm.userPlan,
          hotelAddOns: allAddOns,
          hotelRooms: hotelVm.rooms,
          hotelTotalDp: totalDp,
        );
      }
    } catch (e) {
      debugPrint('Error printing: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencetak: $e')));
      }
    }

    setState(() => _isPrinting = false);
    _cancelSelection();
  }

  Future<void> _printReport(BuildContext context, FinancialViewModel vm, GroomingViewModel groomingVm) async {
    try {
      await PdfGenerator.printFinancialReport(
        month: vm.currentMonth,
        income: vm.monthlyIncome,
        expense: vm.monthlyExpense,
        expenses: vm.expenses,
        businessName: groomingVm.businessName,
        businessPhone: groomingVm.businessPhone,
        businessAddress: groomingVm.businessAddress,
        logoPath: groomingVm.logoPath,
        userPlan: groomingVm.userPlan,
      );
    } catch (e) {
      debugPrint('Error printing report: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mencetak: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModels
    final vm = context.watch<FinancialViewModel>();
    final groomingVm = context.watch<GroomingViewModel>();
    
    // Theme & State
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonth = vm.currentMonth;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _isSelecting
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _cancelSelection,
                ),
                title: Text('${_selectedKeys.length} dipilih'),
                actions: [
                  _isPrinting
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.print_rounded),
                          tooltip: 'Cetak Invoice Gabungan',
                          onPressed: _selectedKeys.isNotEmpty
                              ? () => _printSelected(context)
                              : null,
                        ),
                ],
              )
            : AppBar(
                title: const Text('Laporan Keuangan'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.print_rounded),
                    tooltip: 'Cetak Laporan',
                    onPressed: () => _printReport(context, vm, groomingVm),
                  ),
                ],
              ),
        floatingActionButton: _isSelecting
            ? null
            : FloatingActionButton(
                onPressed: () => _showExpenseDialog(context, vm),
                child: const Icon(Icons.add_rounded),
              ),
        body: Column(
          children: [
            // ─── Month Selector ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   IconButton(
                    onPressed: () => vm.setMonth(DateTime(currentMonth.year, currentMonth.month - 1)),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text(
                    '${_monthName(currentMonth.month)} ${currentMonth.year}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => vm.setMonth(DateTime(currentMonth.year, currentMonth.month + 1)),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),

            // ─── Horizontal Summary ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _SummaryItem('Pemasukan', vm.monthlyIncome, Colors.green, isDark)),
                    const VerticalDivider(width: 16),
                    Expanded(child: _SummaryItem('Pengeluaran', vm.monthlyExpense, Colors.redAccent, isDark)),
                    const VerticalDivider(width: 16),
                     Expanded(child: _SummaryItem('Laba Bersih', vm.monthlyIncome - vm.monthlyExpense, Colors.blue, isDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Tabs ───────────────────────────────────────────────────────
            const TabBar(
              tabs: [
                Tab(text: 'Pemasukan'),
                Tab(text: 'Pengeluaran'),
              ],
            ),

            // ─── Selection Owner Hint ───────────────────────────────────────
            if (_isSelecting && _lockedOwnerName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, size: 16,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Owner: $_lockedOwnerName — hanya transaksi dari owner ini',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            
            // ─── Tab View ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _IncomeTab(
                    vm: vm,
                    groomingVm: groomingVm,
                    isDark: isDark,
                    isSelecting: _isSelecting,
                    selectedKeys: _selectedKeys,
                    lockedOwnerName: _lockedOwnerName,
                    txnKey: _txnKey,
                    onTap: (txn) {
                      if (_isSelecting) {
                        _toggleSelection(txn);
                      } else {
                        // Navigate to detail
                        if (txn is Session) {
                          Navigator.pushNamed(context, '/session_detail', arguments: txn.sessionId);
                        }
                      }
                    },
                    onLongPress: (txn) {
                      if (!_isSelecting) {
                        _enterSelection(txn);
                      }
                    },
                  ),
                  _ExpenseTab(vm: vm, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[month - 1];
  }

  void _showExpenseDialog(BuildContext context, FinancialViewModel vm) {
    final noteCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Keterangan'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(labelText: 'Jumlah (Rp)', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final note = noteCtrl.text.trim();
              final raw = amountCtrl.text.replaceAll('.', '');
              final amount = double.tryParse(raw) ?? 0;
              if (note.isEmpty || amount <= 0) return;
              await vm.addExpense(note, amount, 'Umum', DateTime.now().millisecondsSinceEpoch);
              if (context.mounted) {
                context.read<GroomingViewModel>().refreshDashboardStats();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDark;

  const _SummaryItem(this.label, this.amount, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          app_date.formatCurrencyDouble(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
           textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _IncomeTab extends StatelessWidget {
  final FinancialViewModel vm;
  final GroomingViewModel groomingVm;
  final bool isDark;
  final bool isSelecting;
  final Set<String> selectedKeys;
  final String? lockedOwnerName;
  final String Function(dynamic) txnKey;
  final void Function(dynamic) onTap;
  final void Function(dynamic) onLongPress;

  const _IncomeTab({
    required this.vm,
    required this.groomingVm,
    required this.isDark,
    required this.isSelecting,
    required this.selectedKeys,
    this.lockedOwnerName,
    required this.txnKey,
    required this.onTap,
    required this.onLongPress,
  });

  String? _getOwnerOfTxn(dynamic txn) {
    int catId;
    if (txn is Session) {
      catId = txn.catId;
    } else if (txn is HotelBooking) {
      catId = txn.catId;
    } else {
      return null;
    }
    final cat = groomingVm.allCats.where((c) => c.catId == catId).firstOrNull;
    return cat?.ownerName;
  }

  @override
  Widget build(BuildContext context) {
     if (vm.isLoading) return const Center(child: CircularProgressIndicator());
     
     final totalIncome = vm.monthlyIncome;
     final groomingPct = totalIncome > 0 ? vm.groomingIncome / totalIncome : 0.0;
     final hotelPct = totalIncome > 0 ? vm.hotelIncome / totalIncome : 0.0;
     final transactions = vm.allTransactions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Breakdown
        Text('Rincian Pemasukan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // Grooming Bar
        _IncomeBar(label: 'Grooming', amount: vm.groomingIncome, percent: groomingPct, color: Colors.green),
        const SizedBox(height: 12),
        // Hotel Bar
        _IncomeBar(label: 'Hotel', amount: vm.hotelIncome, percent: hotelPct, color: Colors.blue),
        
        const SizedBox(height: 24),
         Text('Riwayat Transaksi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (!isSelecting)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(
              'Tekan lama untuk memilih & cetak invoice gabungan (1 owner)',
              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey : Colors.grey[600]),
            ),
          ),
        const SizedBox(height: 8),
        
        if (transactions.isEmpty)
           Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Belum ada transaksi.', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]))),
          )
        else
          ...transactions.map((txn) {
             final isSession = txn is Session;
             final date = isSession ? txn.timestamp : (txn as HotelBooking).checkOutDate;
             final double amount = isSession ? (txn).totalCost.toDouble() : (txn as HotelBooking).totalCost;
             final catId = isSession ? txn.catId : (txn as HotelBooking).catId;
             final catName = vm.getCatName(catId);
             final key = txnKey(txn);
             final isSelected = selectedKeys.contains(key);
             final owner = _getOwnerOfTxn(txn);
             final isDifferentOwner = isSelecting && lockedOwnerName != null && owner != lockedOwnerName;
             
             final title = isSession 
                 ? 'Grooming - $catName' 
                 : 'Hotel - $catName';
             
             return Opacity(
               opacity: isDifferentOwner ? 0.4 : 1.0,
               child: Card(
                 margin: const EdgeInsets.only(bottom: 8),
                 color: isSelected
                     ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                     : null,
                 child: ListTile(
                   leading: isSelecting
                       ? Icon(
                           isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                           color: isSelected
                               ? Theme.of(context).colorScheme.primary
                               : Theme.of(context).colorScheme.outline,
                         )
                       : CircleAvatar(
                           backgroundColor: (isSession ? Colors.green : Colors.blue).withValues(alpha: 0.1),
                           child: Icon(
                             isSession ? Icons.pets : Icons.hotel, 
                             color: isSession ? Colors.green : Colors.blue,
                             size: 20,
                           ),
                         ),
                   title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                   subtitle: Text(app_date.formatDateTime(date)),
                   trailing: Text(
                     app_date.formatCurrencyDouble(amount),
                     style: const TextStyle(fontWeight: FontWeight.bold),
                   ),
                   onTap: () => onTap(txn),
                   onLongPress: () => onLongPress(txn),
                 ),
               ),
             );
          }),
      ],
    );
  }
}

class _IncomeBar extends StatelessWidget {
  final String label;
  final double amount;
  final double percent;
  final Color color;

  const _IncomeBar({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(app_date.formatCurrencyDouble(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: color.withValues(alpha: 0.2),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('${(percent * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}

class _ExpenseTab extends StatelessWidget {
  final FinancialViewModel vm;
  final bool isDark;

  const _ExpenseTab({required this.vm, required this.isDark});

  @override
  Widget build(BuildContext context) {
      if (vm.expenses.isEmpty) {
        return Center(
          child: Text('Belum ada pengeluaran.', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
        );
      }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.expenses.length,
      itemBuilder: (context, index) {
        final expense = vm.expenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              child: const Icon(Icons.money_off_rounded, color: Colors.redAccent, size: 20),
            ),
            title: Text(expense.note, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(app_date.formatDateTime(expense.date)),
            trailing: Text(
              app_date.formatCurrencyDouble(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            onLongPress: () => _showDeleteConfirm(context, vm, expense),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, FinancialViewModel vm, dynamic expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Hapus pengeluaran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await vm.deleteExpense(expense);
              if (context.mounted) {
                context.read<GroomingViewModel>().refreshDashboardStats();
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
