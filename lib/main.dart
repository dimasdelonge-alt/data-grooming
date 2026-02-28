import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:datagrooming_v3/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'data/source/database_helper.dart';
import 'data/source/grooming_dao.dart';
import 'data/repository/grooming_repository.dart';
import 'data/repository/firebase_repository.dart';
import 'util/settings_preferences.dart';
import 'util/notification_service.dart';
import 'ui/grooming_view_model.dart';
import 'ui/hotel_view_model.dart';
import 'ui/financial_view_model.dart';
import 'ui/theme/theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/cat_list_screen.dart';
import 'ui/screens/cat_entry_screen.dart';
import 'ui/screens/cat_detail_screen.dart';
import 'ui/screens/session_entry_screen.dart';
import 'ui/screens/session_detail_screen.dart';
import 'ui/screens/session_list_screen.dart';
import 'ui/screens/booking_screen.dart';
import 'ui/screens/calendar_screen.dart';
import 'ui/screens/service_list_screen.dart';
import 'ui/screens/hotel_screen.dart';
import 'ui/screens/room_detail_screen.dart';
import 'ui/screens/financial_screen.dart';
import 'ui/screens/deposit_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/account_screen.dart';
import 'ui/screens/lock_screen.dart';
import 'ui/screens/login_screen.dart';
import 'util/security_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  if (kIsWeb) {
    databaseFactory = createDatabaseFactoryFfiWeb(noWebWorker: true);
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop only — use FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android/iOS: use default sqflite (no init needed)
  
  // Initialize Notifications (skip on web)
  if (!kIsWeb) {
    final notifService = NotificationService();
    await notifService.init();
    await notifService.requestPermissions();
  }

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final settingsPrefs = SettingsPreferences(prefs);
  final firebaseRepo = FirebaseRepository();
  final dao = GroomingDao(DatabaseHelper.instance);
  final repository = GroomingRepository(dao, firebaseRepo, settingsPrefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GroomingViewModel(repository, firebaseRepo, settingsPrefs),
        ),
        ChangeNotifierProvider(
          create: (_) => HotelViewModel(repository),
        ),
        ChangeNotifierProvider(
          create: (_) => FinancialViewModel(repository),
        ),
      ],
      child: const JeniCathouseApp(),
    ),
  );
}

class JeniCathouseApp extends StatelessWidget {
  const JeniCathouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for theme changes
    final vm = context.watch<GroomingViewModel>();

    return MaterialApp(
      title: 'Data Grooming App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: vm.themeMode,
      locale: Locale(vm.currentLanguage),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id'), // Indonesian
        Locale('en'), // English
        Locale('ms'), // Malay
      ],
      home: const _HomeWrapper(),
      builder: (context, child) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/cat_list':
            return MaterialPageRoute(builder: (_) => const CatListScreen());
          case '/cat_entry':
            final catId = settings.arguments as int?;
            return MaterialPageRoute(builder: (_) => CatEntryScreen(catId: catId));
          case '/cat_detail':
            final catId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => CatDetailScreen(catId: catId));
          case '/session_entry':
            final args = settings.arguments;
            int? sessionId;
            int? catId;
            if (args is int) {
              sessionId = args;
            } else if (args is Map) {
              sessionId = args['sessionId'] as int?;
              catId = args['catId'] as int?;
            }
            return MaterialPageRoute(
              builder: (_) => SessionEntryScreen(sessionId: sessionId, preSelectedCatId: catId),
            );
          case '/session_detail':
            final sessionId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => SessionDetailScreen(sessionId: sessionId));
          case '/session_list':
            return MaterialPageRoute(builder: (_) => const SessionListScreen());
          case '/booking':
            return MaterialPageRoute(builder: (_) => const BookingScreen());
          case '/calendar':
            return MaterialPageRoute(builder: (_) => const CalendarScreen());
          case '/service_list':
            return MaterialPageRoute(builder: (_) => const ServiceListScreen());
          case '/hotel':
            return MaterialPageRoute(builder: (_) => const HotelScreen());
          case '/room_detail':
            final roomId = settings.arguments as int;
            return MaterialPageRoute(builder: (_) => RoomDetailScreen(roomId: roomId));
          case '/financial':
            return MaterialPageRoute(builder: (_) => const FinancialScreen());
          case '/deposit':
            return MaterialPageRoute(builder: (_) => const DepositScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/account':
            return MaterialPageRoute(builder: (_) => const AccountScreen());
          default:
            return null;
        }
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isLocked = true;
  SecurityPreferences? _securityPrefs;

  @override
  void initState() {
    super.initState();
    _initSecurity();
  }

  Future<void> _initSecurity() async {
    final prefs = await SharedPreferences.getInstance();
    final sp = SecurityPreferences(prefs);
    setState(() {
      _securityPrefs = sp;
      _isLocked = sp.isAppLockEnabled;
    });
  }

  // Pages — Dashboard is real, others are placeholders until built
  final List<Widget> _pages = const [
    DashboardScreen(),
    SessionListScreen(),
    SizedBox(), // FAB placeholder (index 2 is never shown)
    FinancialScreen(),
    AccountScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) return; // Center is FAB, ignore
    setState(() => _currentIndex = index);
  }

  void _onFabPressed() {
    // Quick action bottom sheet
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return _QuickActionSheet(
          l10n: l10n,
          onNewSession: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/session_entry');
          },
          onCheckIn: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/hotel');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked && _securityPrefs != null && _securityPrefs!.isAppLockEnabled) {
      return LockScreen(
        securityPrefs: _securityPrefs!,
        onUnlock: () => setState(() => _isLocked = false),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: l10n.home,
                isSelected: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
                index: 0,
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: l10n.activity,
                isSelected: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
                index: 1,
              ),
              const SizedBox(width: 48), // Space for FAB
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: l10n.financial,
                isSelected: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
                index: 3,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.account,
                isSelected: _currentIndex == 4,
                onTap: () => _onTabTapped(4),
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Item ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? AppColors.accentByIndex(index)
        : AppColors.lightPrimaryDark;
    final inactiveColor = isDark
        ? AppColors.darkSubtext
        : AppColors.lightSubtext;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Action Bottom Sheet ───────────────────────────────────────────────

class _QuickActionSheet extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onNewSession;
  final VoidCallback onCheckIn;

  const _QuickActionSheet({
    required this.l10n,
    required this.onNewSession,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSubtext : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.quickAction,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.content_cut_rounded,
                  label: l10n.newSession,
                  color: isDark ? AppColors.accentGreen : AppColors.lightPrimary,
                  onTap: onNewSession,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.hotel_rounded,
                  label: l10n.hotelCheckIn,
                  color: isDark ? AppColors.accentPurple : AppColors.lightPrimaryDark,
                  onTap: onCheckIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wrapper that shows LoginScreen on web if user hasn't logged in yet.
class _HomeWrapper extends StatefulWidget {
  const _HomeWrapper();

  @override
  State<_HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<_HomeWrapper> {
  bool _isLoggedIn = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final vm = context.read<GroomingViewModel>();
      _isLoggedIn = !kIsWeb || vm.currentShopId.isNotEmpty;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && !_isLoggedIn) {
      final vm = context.read<GroomingViewModel>();
      return LoginScreen(
        settingsPrefs: vm.settingsPrefs,
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
          // Auto-sync from cloud after login
          vm.restoreData();
        },
      );
    }
    return const MainShell();
  }
}
