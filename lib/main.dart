import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/stage_provider.dart';
import 'core/theme/colors.dart';
import 'services/storage_service.dart';
import 'screens/splash/splash_screen.dart';

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
      ],
      child: Consumer<LanguageProvider>(
        builder: (_, lang, __) => MaterialApp(
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
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
