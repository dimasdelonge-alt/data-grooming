import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../../data/entity/grooming_service.dart';
import '../../util/date_utils.dart' as app_date;
import '../../util/currency_formatter.dart';
import '../common/empty_state.dart';

/// CRUD screen for grooming services (price list).
class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final services = vm.services;

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Layanan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(context, vm),
        child: const Icon(Icons.add_rounded),
      ),
      body: services.isEmpty
          ? const EmptyState(
              message: 'Belum ada layanan.',
              subMessage: 'Tap tombol + untuk menambah layanan.',
              icon: Icons.spa_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final svc = services[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.lightPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.content_cut_rounded, color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(svc.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(app_date.formatCurrencyInt(svc.defaultPrice), style: TextStyle(color: isDark ? AppColors.accentBlue : AppColors.lightPrimaryDark, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showServiceDialog(context, vm, service: svc),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          onPressed: () => _showDeleteDialog(context, vm, svc),
                          icon: Icon(Icons.delete_rounded, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showServiceDialog(BuildContext context, GroomingViewModel vm, {GroomingService? service}) {
    final nameController = TextEditingController(text: service?.serviceName ?? '');
    final priceController = TextEditingController(text: service?.defaultPrice.toString() ?? '');
    bool nameError = false;
    bool priceError = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDlgState) {
          return AlertDialog(
            title: Text(service != null ? 'Edit Layanan' : 'Tambah Layanan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Layanan', errorText: nameError ? 'Wajib diisi' : null),
                  onChanged: (_) => setDlgState(() => nameError = false),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Harga (Rp)', prefixText: 'Rp ', errorText: priceError ? 'Harga tidak valid' : null),
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  onChanged: (_) => setDlgState(() => priceError = false),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final rawPrice = priceController.text.replaceAll('.', '');
                  final price = int.tryParse(rawPrice);
                  if (name.isEmpty) {
                    setDlgState(() => nameError = true);
                    return;
                  }
                  if (price == null) {
                    setDlgState(() => priceError = true);
                    return;
                  }
                  if (service != null) {
                    vm.updateService(service.copyWith(serviceName: name, defaultPrice: price));
                  } else {
                    vm.addService(name, price);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteDialog(BuildContext context, GroomingViewModel vm, GroomingService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text('Hapus "${service.serviceName}" secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              vm.deleteService(service);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
