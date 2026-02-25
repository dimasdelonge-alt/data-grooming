import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../financial_view_model.dart';
import '../grooming_view_model.dart';
import '../../data/entity/deposit_entities.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/currency_formatter.dart';
import '../../util/pdf_generator.dart';
import '../../util/phone_number_utils.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinancialViewModel>();
    final allDeposits = vm.deposits;
    final query = _search.trim().toLowerCase();

    final deposits = query.isEmpty
        ? allDeposits
        : allDeposits.where((d) =>
            d.ownerName.toLowerCase().contains(query) ||
            d.ownerPhone.contains(query)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Deposit Pelanggan')),
      floatingActionButton: FilledButton.icon(
        onPressed: () => _showTopUpDialog(context, vm),
        label: const Text('Top Up'),
        icon: const Icon(Icons.add_card_rounded),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari Nama / No HP',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Deposit list
          Expanded(
            child: deposits.isEmpty
                ? const Center(child: Text('Belum ada data deposit.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: deposits.length,
                    itemBuilder: (context, index) {
                      final deposit = deposits[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            child: Text(deposit.ownerName.isNotEmpty ? deposit.ownerName[0].toUpperCase() : '?'),
                          ),
                          title: Text(deposit.ownerName.isNotEmpty ? deposit.ownerName : 'No Name',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(deposit.ownerPhone),
                          trailing: Text(
                            app_date.formatCurrencyDouble(deposit.balance),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: deposit.balance >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                          onTap: () => _showDetailDialog(context, vm, deposit),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── TOP UP DIALOG ─────────────────────────────────────────────────

  void _showTopUpDialog(BuildContext context, FinancialViewModel vm, {String? prefillPhone, String? prefillName}) {
    final phoneController = TextEditingController(text: prefillPhone ?? '');
    final nameController = TextEditingController(text: prefillName ?? '');
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final isExisting = prefillPhone != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isExisting ? 'Top Up Saldo' : 'Deposit Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isExisting) ...[
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'No. HP (ID)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Pemilik'),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Jumlah Top Up', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Catatan (Opsional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final raw = amountController.text.replaceAll('.', '');
              final amount = double.tryParse(raw);
              final phone = PhoneNumberUtils.normalize(phoneController.text.trim());
              final name = nameController.text.trim();
              if (phone.isNotEmpty && name.isNotEmpty && amount != null && amount > 0) {
                await vm.topUpDeposit(phone, name, amount, notesController.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ─── DETAIL / HISTORY DIALOG ───────────────────────────────────────

  void _showDetailDialog(BuildContext context, FinancialViewModel vm, OwnerDeposit deposit) {
    showDialog(
      context: context,
      builder: (ctx) => _DepositDetailDialog(vm: vm, deposit: deposit, parentContext: context),
    );
  }
}

// Stateful dialog to handle sub-dialogs properly
class _DepositDetailDialog extends StatelessWidget {
  final FinancialViewModel vm;
  final OwnerDeposit deposit;
  final BuildContext parentContext;

  const _DepositDetailDialog({required this.vm, required this.deposit, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    // Watch VM to get latest deposit data
    final freshVm = context.watch<FinancialViewModel>();
    final freshDeposit = freshVm.deposits.where((d) => d.ownerPhone == deposit.ownerPhone).firstOrNull ?? deposit;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history),
          const SizedBox(width: 8),
          Expanded(child: Text('Riwayat: ${freshDeposit.ownerName}', overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance
            Text('Saldo Saat Ini: ${app_date.formatCurrencyDouble(freshDeposit.balance)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
            Text('HP: ${freshDeposit.ownerPhone}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),

            // Share history button
            OutlinedButton.icon(
              onPressed: () {
                final groomingVm = context.read<GroomingViewModel>();
                vm.getTransactions(freshDeposit.ownerPhone).first.then((txns) {
                  PdfGenerator.printDepositHistory(
                    ownerName: freshDeposit.ownerName,
                    ownerPhone: freshDeposit.ownerPhone,
                    currentBalance: freshDeposit.balance,
                    transactions: txns,
                    businessName: groomingVm.businessName,
                    logoPath: groomingVm.logoPath,
                  );
                });
              },
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Bagikan Riwayat (Rekening Koran)', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
            ),
            const SizedBox(height: 8),

            // Transaction History
            const Divider(),
            Flexible(
              child: StreamBuilder<List<DepositTransaction>>(
                stream: vm.getTransactions(freshDeposit.ownerPhone),
                builder: (ctx, snapshot) {
                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Belum ada transaksi.')),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: transactions.length,
                    separatorBuilder: (_, a) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final txn = transactions[i];
                      final isCredit = txn.amount >= 0;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        title: Text(_transactionLabel(txn.type), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app_date.formatDateTime(txn.timestamp), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (txn.notes.isNotEmpty)
                              Text(txn.notes, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              app_date.formatCurrencyDouble(txn.amount),
                              style: TextStyle(
                                color: isCredit ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (txn.type == TransactionType.topup)
                              IconButton(
                                icon: const Icon(Icons.share, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: () {
                                  final groomingVm = context.read<GroomingViewModel>();
                                  PdfGenerator.printDepositReceipt(
                                    transaction: txn,
                                    ownerName: freshDeposit.ownerName,
                                    currentBalance: freshDeposit.balance,
                                    businessName: groomingVm.businessName,
                                    logoPath: groomingVm.logoPath,
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAdjustDialog(context, vm, freshDeposit),
                    child: const Text('Adjust Saldo', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteConfirm(context, vm, freshDeposit),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Hapus', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            final state = parentContext.findAncestorStateOfType<_DepositScreenState>();
            state?._showTopUpDialog(
              parentContext,
              vm,
              prefillPhone: freshDeposit.ownerPhone,
              prefillName: freshDeposit.ownerName,
            );
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Top Up Lagi'),
        ),
      ],
    );
  }

  String _transactionLabel(TransactionType type) {
    switch (type) {
      case TransactionType.topup: return 'Top Up';
      case TransactionType.groomingPayment: return 'Bayar Grooming';
      case TransactionType.hotelPayment: return 'Bayar Hotel';
      case TransactionType.adjustment: return 'Penyesuaian';
      case TransactionType.refund: return 'Refund';
    }
  }

  void _showAdjustDialog(BuildContext dialogContext, FinancialViewModel vm, OwnerDeposit deposit) {
    final amountController = TextEditingController(text: deposit.balance.toInt().toString());
    final notesController = TextEditingController();

    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo saat ini: ${app_date.formatCurrencyDouble(deposit.balance)}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Saldo Baru', prefixText: 'Rp '),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Alasan (Opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              final raw = amountController.text.replaceAll('.', '');
              final newBalance = double.tryParse(raw);
              if (newBalance != null) {
                await vm.adjustBalance(deposit.ownerPhone, newBalance, notesController.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext dialogContext, FinancialViewModel vm, OwnerDeposit deposit) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Deposit'),
        content: Text('Hapus deposit ${deposit.ownerName}? Semua riwayat transaksi akan ikut terhapus. Data tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              await vm.deleteDeposit(deposit.ownerPhone);
              if (ctx.mounted) Navigator.pop(ctx); // Close delete confirm
              if (dialogContext.mounted) Navigator.pop(dialogContext); // Close detail dialog
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
