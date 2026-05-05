import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/stage_provider.dart';
import 'core/providers/xp_provider.dart';
import 'core/providers/partner_provider.dart';
import 'core/theme/colors.dart';
import 'services/storage_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/partner_mode/partner_entry_screen.dart';
import 'models/partner_model.dart';

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
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => StageProvider()),
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
          home: _AppRouter(partner: partner),
        ),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  final PartnerProvider partner;
  const _AppRouter({required this.partner});

  @override
  Widget build(BuildContext context) {
    switch (partner.appMode) {
      case AppMode.partner:
        return const PartnerHomeScreen();
      default:
        return const SplashScreen();
    }
  }
}
