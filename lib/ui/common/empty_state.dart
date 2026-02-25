import 'package:flutter/material.dart';
import '../theme/theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? subMessage;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.search_off_rounded,
    this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
