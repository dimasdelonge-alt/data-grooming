import 'package:flutter/material.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final allDeposits = vm.deposits;
    final query = _search.trim().toLowerCase();

    final deposits = query.isEmpty
        ? allDeposits
        : allDeposits.where((d) =>
            d.ownerName.toLowerCase().contains(query) ||
            d.ownerPhone.contains(query)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerDeposit)),
      floatingActionButton: FilledButton.icon(
        onPressed: () => _showTopUpDialog(context, vm, l10n),
        label: Text(l10n.topUp),
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
                hintText: l10n.searchNamePhone,
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
                ? Center(child: Text(l10n.noDepositData, style: const TextStyle(color: Colors.grey)))
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
                          title: Text(deposit.ownerName.isNotEmpty ? deposit.ownerName : l10n.noName,
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

  void _showTopUpDialog(BuildContext context, FinancialViewModel vm, AppLocalizations l10n, {String? prefillPhone, String? prefillName}) {
    final phoneController = TextEditingController(text: prefillPhone ?? '');
    final nameController = TextEditingController(text: prefillName ?? '');
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final isExisting = prefillPhone != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isExisting ? l10n.topUpBalance : l10n.newDeposit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isExisting) ...[
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: l10n.phoneId),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.ownerName),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: l10n.topUpAmount, prefixText: 'Rp '),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: l10n.notesOptional),
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
      builder: (ctx) => _DepositDetailDialog(vm: vm, deposit: deposit, parentContext: context, l10n: AppLocalizations.of(context)!),
    );
  }
}

// Stateful dialog to handle sub-dialogs properly
class _DepositDetailDialog extends StatelessWidget {
  final FinancialViewModel vm;
  final OwnerDeposit deposit;
  final BuildContext parentContext;

  final AppLocalizations l10n;
  const _DepositDetailDialog({required this.vm, required this.deposit, required this.parentContext, required this.l10n});

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
          Expanded(child: Text(l10n.historyPrefix(freshDeposit.ownerName), overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance
            Text(l10n.currentBalanceValue(app_date.formatCurrencyDouble(freshDeposit.balance)),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
            Text(l10n.ownerPhoneValue(freshDeposit.ownerPhone), style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
              label: Text(l10n.shareHistoryStatement, style: const TextStyle(fontSize: 12)),
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
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: Text(l10n.noTransactions)),
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
                        title: Text(_transactionLabel(txn.type, l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                    onPressed: () => _showAdjustDialog(context, vm, freshDeposit, l10n),
                    child: Text(l10n.adjustBalance, style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDeleteConfirm(context, vm, freshDeposit, l10n),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.delete, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
  actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            final state = parentContext.findAncestorStateOfType<_DepositScreenState>();
            state?._showTopUpDialog(
              parentContext,
              vm,
              l10n,
              prefillPhone: freshDeposit.ownerPhone,
              prefillName: freshDeposit.ownerName,
            );
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          child: Text(l10n.topUpAgain),
        ),
      ],
    );
  }

  String _transactionLabel(TransactionType type, AppLocalizations l10n) {
    switch (type) {
      case TransactionType.topup: return l10n.transTopUp;
      case TransactionType.groomingPayment: return l10n.transGroomingPayment;
      case TransactionType.hotelPayment: return l10n.transHotelPayment;
      case TransactionType.adjustment: return l10n.transAdjustment;
      case TransactionType.refund: return l10n.transRefund;
    }
  }

  void _showAdjustDialog(BuildContext dialogContext, FinancialViewModel vm, OwnerDeposit deposit, AppLocalizations l10n) {
    final amountController = TextEditingController(text: deposit.balance.toInt().toString());
    final notesController = TextEditingController();

    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.adjustBalance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.currentBalanceValue(app_date.formatCurrencyDouble(deposit.balance)),
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: l10n.newBalance, prefixText: 'Rp '),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: l10n.adjustmentReason),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final raw = amountController.text.replaceAll('.', '');
              final newBalance = double.tryParse(raw);
              if (newBalance != null) {
                await vm.adjustBalance(deposit.ownerPhone, newBalance, notesController.text);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext dialogContext, FinancialViewModel vm, OwnerDeposit deposit, AppLocalizations l10n) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDeposit),
        content: Text(l10n.deleteDepositConfirm(deposit.ownerName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              await vm.deleteDeposit(deposit.ownerPhone);
              if (ctx.mounted) Navigator.pop(ctx); // Close delete confirm
              if (dialogContext.mounted) Navigator.pop(dialogContext); // Close detail dialog
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
