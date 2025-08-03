import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppLocalizations.dart'; // Your localization class

// These will be uncommented once the other files are added
 import 'customer.dart';
// import 'airplane.dart';
// import 'flights.dart';
// import 'reservation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = Locale('en'); // Default language

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multilingual App',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        )
      ),
      home: HomePage(
          locale:_locale,
          onLanguageChanged: _changeLanguage),
    );
  }
}

class HomePage extends StatelessWidget {
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const HomePage({
    Key? key,
    required this.locale,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('home_title') ?? 'Main Menu'),
        actions: [
          Container(
            color: Colors.blue, // Same as AppBar color
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.blue,            // Dropdown menu background
                  highlightColor: Colors.blue[800],    // Selected item highlight
                  splashColor: Colors.blue[700],       // Tap ripple color
                  textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white,           // Menu item text color
                    displayColor: Colors.white,
                  ),
                ),
                child: DropdownButton<Locale>(
                  value: locale,
                  icon: Icon(Icons.language, color: Colors.white),
                  dropdownColor: Colors.blue,
                  onChanged: (locale) {
                    if (locale != null) onLanguageChanged(locale);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('fr'),
                      child: Text('Français'),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),

      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/main_bg.jpg', // Make sure this image exists and is declared in pubspec.yaml
              fit: BoxFit.cover,
              alignment: Alignment.center,//adjust which part of the picture shows in the page
            ),
          ),
          // Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // These will be replaced with real navigation once pages are merged
                buildImageButton(context, t.translate('customer') ?? 'Customer (TODO)', CustomerPage(
                  locale:locale,
                  onLanguageChanged: onLanguageChanged,
                )),
                buildImageButton(context, t.translate('airplane') ?? 'Airplane (TODO)', Placeholder()),
                buildImageButton(context, t.translate('flights') ?? 'Flights (TODO)', Placeholder()),
                buildImageButton(context, t.translate('reservation') ?? 'Reservation (TODO)', Placeholder()),

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        child: Ink(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/button_bg.png'), // button background image file
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
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black54,
                    offset: Offset(1, 1),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
//comments for new branch