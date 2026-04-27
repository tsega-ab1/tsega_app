import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ── PROVIDERS ────────────────────────────────────────────────────
import 'core/providers/language_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/stage_provider.dart';
import 'core/providers/xp_provider.dart';          // NEW — gamification
import 'core/providers/partner_provider.dart';      // NEW — partner mode

// ── SERVICES ─────────────────────────────────────────────────────
import 'core/theme/colors.dart';
import 'services/storage_service.dart';

// ── ENTRY SCREENS ────────────────────────────────────────────────
import 'screens/splash/splash_screen.dart';
import 'screens/partner_mode/partner_entry_screen.dart'; // NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const TsegaApp());
}

class TsegaApp extends StatelessWidget {
  const TsegaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── EXISTING ───────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StageProvider()),

        // ── NEW ─────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => XpProvider()),
        ChangeNotifierProvider(create: (_) => PartnerProvider()),
      ],
      child: Consumer2<LanguageProvider, PartnerProvider>(
        builder: (_, lang, partner, __) => MaterialApp(
          title: 'Tsega ጸጋ',
          debugShowCheckedModeBanner: false,
          locale: Locale(lang.languageCode),
          theme: ThemeData(
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: TColors.teal500,
              primary: TColors.teal500,
              secondary: TColors.pink500,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: TColors.cream,
            appBarTheme: const AppBarTheme(
              backgroundColor: TColors.teal700,
              foregroundColor: TColors.white,
              elevation: 0,
            ),
          ),
          // ── ROUTING LOGIC ───────────────────────────────────
          // Decides whether to show woman's app or partner mode
          home: _AppRouter(partner: partner),
        ),
      ),
    );
  }
}

// ── APP ROUTER ───────────────────────────────────────────────────
// Checks if this device is in partner mode or woman mode
// Partner mode is set permanently after entering invite code
class _AppRouter extends StatelessWidget {
  final PartnerProvider partner;
  const _AppRouter({required this.partner});

  @override
  Widget build(BuildContext context) {
    switch (partner.appMode) {
      // Device has been linked as a partner — go straight to partner home
      case AppMode.partner:
        return const PartnerHomeScreen();

      // Normal woman's app — go through splash → onboarding → home
      case AppMode.woman:
      case AppMode.unknown:
      default:
        return const SplashScreen();
    }
  }
}
