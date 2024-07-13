import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:werdy/bloc/home/home_cubit.dart';
import 'package:werdy/presentation/screens/hadith/hadith_details_screen.dart'; // Import added
import 'package:werdy/presentation/screens/hadith/hadith_name_screen.dart';
import 'package:werdy/presentation/screens/home/home_tab.dart';
import 'package:werdy/presentation/screens/quran/quran_tab.dart';
import 'package:werdy/presentation/screens/tasbeh/tasbeh.dart';

import 'bloc/tesbeh/tesbeh_cubit.dart';
import 'presentation/screens/home/homeScreen.dart';
import 'presentation/screens/quran/sura_screen.dart';
import 'presentation/theme/theme_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeCubit(),
          ),
          BlocProvider(
            create: (context) => TesbehCubit(),
          ),
        ],
        child: MaterialApp(
          theme: MyThemeData.lightTheme,
          darkTheme: MyThemeData.darkTheme,
          initialRoute: MyHomePage.routeName,
          routes: {
            MyHomePage.routeName: (context) => MyHomePage(),
            HomeTab.routeName: (context) => HomeTab(),
            SuraScreen.routeName: (context) => SuraScreen(),
            QuranTab.routeName: (context) => QuranTab(),
            HadithDetailsScreen.routeName: (context) => HadithDetailsScreen(),
            HadithNameScreen.routeName: (context) => HadithNameScreen(),
            TasbehTab.routeName: (context) => TasbehTab()
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Spanish
          ],
          locale: const Locale('ar'),
        ),
      ),
    );
  }
}
