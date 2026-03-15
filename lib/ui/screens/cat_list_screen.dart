import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../common/empty_state.dart';
import '../../data/entity/cat.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.catListCount(cats.length)),
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
                    Text(vm.showArchivedCats ? AppLocalizations.of(context)!.hideArchived : AppLocalizations.of(context)!.viewArchived),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Semua Kucing'),
            Tab(text: 'Berdasarkan Pemilik'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Search Bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: vm.onSearchQueryChanged,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchCatOrOwner,
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
          // ─── Tab Views ──────────────────────────────────────
          Expanded(
            child: TabBarView(
              children: [
                // TAB 1: Semua Kucing (Existing List)
                cats.isEmpty
                    ? EmptyState(
                        message: vm.searchQuery.isNotEmpty
                            ? AppLocalizations.of(context)!.noCatsMatchSearch
                            : AppLocalizations.of(context)!.noCatDataYet,
                        subMessage: vm.searchQuery.isNotEmpty
                            ? AppLocalizations.of(context)!.tryAnotherKeyword
                            : AppLocalizations.of(context)!.tapPlusToAddCat,
                        icon: vm.searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.pets_rounded,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                        itemCount: cats.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final cat = cats[index];
                          return _buildCatCard(context, cat, isStarter, allowedIds, isDark);
                        },
                      ),

                // TAB 2: Berdasarkan Pemilik
                Builder(
                  builder: (context) {
                    // Extract owners from filtered cats to respect search query and archive settings
                    final Map<String, List<Cat>> ownerCatsMap = {};
                    for (var cat in cats) {
                      ownerCatsMap.putIfAbsent(cat.ownerName, () => []).add(cat);
                    }
                    final ownersList = ownerCatsMap.keys.toList()..sort();

                    if (ownersList.isEmpty) {
                      return EmptyState(
                        message: vm.searchQuery.isNotEmpty
                            ? AppLocalizations.of(context)!.noCatsMatchSearch
                            : 'Tidak ada data pemilik',
                        subMessage: vm.searchQuery.isNotEmpty
                            ? AppLocalizations.of(context)!.tryAnotherKeyword
                            : 'Tambah kucing untuk melihat data pemilik',
                        icon: Icons.person_off_rounded,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: ownersList.length,
                      itemBuilder: (context, index) {
                        final ownerName = ownersList[index];
                        final ownerCats = ownerCatsMap[ownerName]!;
                        // Use the first cat's owner phone, if needed, but not strictly necessary here.
                        
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
                              ),
                              title: Text(
                                ownerName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              subtitle: Text(
                                '${ownerCats.length} Kucing',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                ),
                              ),
                              children: ownerCats.map((cat) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  child: _buildCatCard(context, cat, isStarter, allowedIds, isDark),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isStarter && allCats.length >= 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.starterLimit15CatsReached)),
            );
          } else {
            Navigator.pushNamed(context, '/cat_entry');
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    ));
  }

  Widget _buildCatCard(BuildContext context, cat, bool isStarter, Set<int> allowedIds, bool isDark) {
    final isLocked = isStarter && !allowedIds.contains(cat.catId);

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.dataLockedStarterLimit)),
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
                        '${cat.breed} • ${_getGenderLabel(cat.gender, AppLocalizations.of(context)!)}',
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
  }

  String _getGenderLabel(String gender, AppLocalizations l10n) {
    if (gender.toLowerCase() == 'male') return l10n.male;
    if (gender.toLowerCase() == 'female') return l10n.female;
    return gender;
  }
}
