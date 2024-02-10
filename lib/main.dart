import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lang_compare/app_theme/theme.dart';
import 'package:lang_compare/models/api-model.dart';
import 'package:lang_compare/models/language-model.dart';
import 'package:lang_compare/navi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(LanguageModelAdapter());
  await Hive.openBox<LanguageModel>('languages');
  Hive.registerAdapter(ApiModelAdapter());
  await Hive.openBox<ApiModel>('apiinfo');
  runApp(
    EasyDynamicThemeWidget(
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isDarkModeOn = Theme.of(context).brightness == Brightness.dark;
    return DynamicColorBuilder(
      builder: (ColorScheme? dayColorScheme, ColorScheme? nightColorScheme){
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lang Compare',
          themeMode: EasyDynamicTheme.of(context).themeMode,
          theme: isDarkModeOn ? AppTheme.darkMode(nightColorScheme) : AppTheme.lightMode(dayColorScheme),
          darkTheme: AppTheme.darkMode(nightColorScheme),
          home: const Navi(),
        );
      },
    );
  }
}
