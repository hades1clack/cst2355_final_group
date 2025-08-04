import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cst2355_final_group/localization/AppLocalizations.dart'; // Your localization class

// These will be uncommented once the other files are added
import 'localization/AppLocalizations.dart'; // Make sure this is your actual localization class
import 'reservation_page.dart';
// TODO: Import other feature pages here once created
// import 'customer.dart';
// import 'airplane.dart';
// import 'flights.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    // final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default language

  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multilingual App',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale("en"),
        Locale("fr"),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: HomePage(
        locale: _locale,
        onLanguageChanged: changeLanguage,
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const HomePage({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('home_title') ?? 'Main Menu'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: locale,
                icon: const Icon(Icons.language, color: Colors.white),
                dropdownColor: Colors.blue,
                onChanged: (locale) {
                  if (locale != null) onLanguageChanged(locale);
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(
                    value: Locale('fr'),
                    child: Text('Français'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/main_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Replace Placeholder() widgets with actual pages
                buildImageButton(
                  context,
                  t.translate('customer') ?? 'Customer',
                  const Placeholder(),
                ),
                buildImageButton(
                  context,
                  t.translate('airplane') ?? 'Airplane',
                  const Placeholder(),
                ),
                buildImageButton(
                  context,
                  t.translate('flights') ?? 'Flights',
                  const Placeholder(),
                ),
                buildImageButton(
                  context,
                  t.translate('reservation') ?? 'Reservation',
                  const ReservationPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Ink(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/button_bg.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 60,
            width: 250,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
