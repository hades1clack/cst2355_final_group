import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'AppLocalizations.dart'; // Your localization class
import 'package:cst2355_final_group/localization/AppLocalizations.dart'; // Your localization class
// These will be uncommented once the other files are added
import 'customer.dart';
// import 'airplane.dart';
// import 'flights.dart';
import 'reservation_page.dart';
/// Entry point of the Flutter application.
void main() {
  runApp(MyApp());
}
/// The root widget of the application that supports dynamic locale switching.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  /// Allows child widgets to update the app's locale using context.
  static void setLocale(BuildContext context, Locale newLocale) {
    final MyAppState? state = context.findAncestorStateOfType<MyAppState>();
    state?._changeLanguage(newLocale);
  }

  @override
  State<MyApp> createState() => MyAppState();
}

/// The state class for [MyApp] that manages the current app locale.
class MyAppState extends State<MyApp> {
  /// Current selected locale. Defaults to English.
  Locale _locale = Locale('en'); // Default language
  /// Callback to change the app's language.
  void _changeLanguage(Locale newLocale) {
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
/// The main menu screen with navigation options and language selection.
class HomePage extends StatelessWidget {
  /// The current locale of the app.
  final Locale locale;
  /// Callback to notify when the language has changed.
  final Function(Locale) onLanguageChanged;
  /// Constructs the [HomePage].
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
          /// Language dropdown menu in the AppBar.
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
          /// Background image for aesthetic design.
          Positioned.fill(
            child: Image.asset(
              'images/main_bg.jpg', // Make sure this image exists and is declared in pubspec.yaml
              fit: BoxFit.cover,
              alignment: Alignment.center,//adjust which part of the picture shows in the page
            ),
          ),
          // Foreground content
          /// Navigation buttons to other modules.
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
                buildImageButton(context, t.translate('reservation') ?? 'Reservation', const ReservationPage()),

              ],
            ),
          ),
        ],
      ),
    );
  }
  /// Builds a clickable button styled with a background image to navigate to a new page.
  ///
  /// - [context]: BuildContext to use for navigation.
  /// - [title]: Button label text.
  /// - [page]: Widget to navigate to when tapped.
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