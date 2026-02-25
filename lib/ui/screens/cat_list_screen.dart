import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../common/empty_state.dart';

class CatListScreen extends StatelessWidget {
  const CatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GroomingViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allCats = vm.allCats;
    final cats = vm.cats;
    final isStarter = vm.userPlan == 'starter';

    // Determine allowed IDs (first 15 by catId) for starter plan
    final allowedIds = isStarter
        ? (List.of(allCats)..sort((a, b) => a.catId.compareTo(b.catId)))
            .take(15)
            .map((c) => c.catId)
            .toSet()
        : <int>{};

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kucing (${cats.length})'),
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: Icon(
              vm.showArchivedCats ? Icons.archive_rounded : Icons.archive_outlined,
              color: vm.showArchivedCats ? Theme.of(context).colorScheme.primary : null,
            ),
            onSelected: (value) {
              if (value == 0) vm.toggleShowArchivedCats();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(
                      vm.showArchivedCats ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(vm.showArchivedCats ? 'Sembunyikan Arsip' : 'Lihat Terarsip'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search Bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: vm.onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: 'Cari kucing atau owner...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ─── Cat List ──────────────────────────────────────
          Expanded(
            child: cats.isEmpty
                ? EmptyState(
                    message: vm.searchQuery.isNotEmpty
                        ? 'Tidak ada kucing yang cocok dengan pencarian.'
                        : 'Belum ada data kucing.',
                    subMessage: vm.searchQuery.isNotEmpty
                        ? 'Coba kata kunci lain.'
                        : 'Tap tombol + untuk menambah kucing.',
                    icon: vm.searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.pets_rounded,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: cats.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cat = cats[index];
                      final isLocked = isStarter && !allowedIds.contains(cat.catId);

                      return Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              if (isLocked) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Data ini terkunci (Limit Starter 15). Silakan upgrade ke PRO!')),
                                );
                              } else {
                                Navigator.pushNamed(context, '/cat_detail', arguments: cat.catId);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CatAvatar(imagePath: cat.imagePath, size: 52),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.catName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${cat.breed} • ${cat.gender}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              size: 14,
                                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              cat.ownerName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (cat.permanentAlert.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent),
                                    ),
                                  if (isLocked) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.lock_rounded, size: 18, color: Colors.red.withValues(alpha: 0.7)),
                                  ],
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isStarter && allCats.length >= 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Batas Starter 15 kucing tercapai! Silakan upgrade ke PRO.')),
            );
          } else {
            Navigator.pushNamed(context, '/cat_entry');
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
