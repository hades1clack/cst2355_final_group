
import 'package:flutter/material.dart';
import 'package:cst2355_final_group/Airdatabase/app_database.dart';
import 'package:cst2355_final_group/Airdatabase/airplane.dart';
import 'package:cst2355_final_group/airplane_detail_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cst2355_final_group/localization/AppLocalizations.dart';

/// Entry point of the app.
/// Initializes the Airdatabase and launches the application.
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}
/// Root widget of the app.
class MyApp extends StatefulWidget {
  /// The Airdatabase instance passed into the app.
  final AppDatabase database;
  /// Creates the main app widget with the given database instance.
  const MyApp(this.database, {Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
 /// This class manages the current locale of the app
 /// and provides a method to update the language dynamically.
  class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  /// This would switch the app's language to French.
  void _changeLanguage(Locale locale) {
  setState(() {
  _locale = locale;
  });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airplane List Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
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

      home: AirplaneListPage(
        locale: _locale,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

/// Main page displaying the list of airplanes.
class AirplaneListPage extends StatefulWidget {
  /// The Airdatabase instance used to retrieve airplane data.
  ///final AppDatabase database;
  final Locale locale;
  /// Callback function to handle language changes.
  final Function(Locale) onLanguageChanged;
  /// Creates an AirplaneListPage with the specified locale and language change handler.
  const AirplaneListPage({Key? key, required this.locale, required this.onLanguageChanged,}) : super(key: key);

  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}
///This state class manages the UI and logic for displaying,
/// adding, editing, and deleting airplane records in the app.
class _AirplaneListPageState extends State<AirplaneListPage> {
  AppDatabase? _database;
  /// Controller for the airplane type input field.
  final TextEditingController _typeController = TextEditingController();
  /// Controller for the passenger count input field.
  final TextEditingController _passengerCountController = TextEditingController();
  /// Controller for the maximum speed input field.
  final TextEditingController _maxSpeedController = TextEditingController();
  /// Controller for the range input field.
  final TextEditingController _rangeController = TextEditingController();
  /// List of airplanes fetched from the Airplanedatabase.
  List<Airplane> airplanes = [];
  /// Currently selected airplane from the list.
  Airplane? _selectedList;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadAirplanesFromDb();
  }
///Initializes the Floor database and loads the list of airplanes.
  Future<void> _initDatabase() async {
    final db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    setState(() {
      _database = db;
    });
    _loadAirplanesFromDb();
  }
  /// Loads all airplane records from the Airdatabase.
  Future<void> _loadAirplanesFromDb() async {
    if(_database == null) return;
    final list = await _database!.airplaneDao.getAllAirplanes();
    setState(() {
      airplanes = list;

      if (_selectedList != null) {
        _selectedList = list.firstWhere(
              (item) => item.id == _selectedList?.id,
          orElse: () => _selectedList!,
        );
      }
    });
  }
  /// Updates the selected airplane with new values from input fields.
  Future<void> _editAirplane() async {
    final type = _typeController.text.trim();
    final passengerCount = int.tryParse(_passengerCountController.text.trim()) ?? 0;
    final maxSpeed = double.tryParse(_maxSpeedController.text.trim()) ?? 0;
    final range = double.tryParse(_rangeController.text.trim()) ?? 0;

    if (type.isNotEmpty && passengerCount > 0 && maxSpeed > 0 && range > 0) {
      final newAirplane = Airplane(
        id: _selectedList!.id,
        type: type,
        passengerCount: passengerCount,
        maxSpeed: maxSpeed,
        range: range,
      );

      await _database!.airplaneDao.updateAirplane(newAirplane);

      _typeController.clear();
      _passengerCountController.clear();
      _maxSpeedController.clear();
      _rangeController.clear();

      await _loadAirplanesFromDb();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //content: Text('Changes saved successfully!'),
          content: Text("${AppLocalizations.of(context)!.translate("Changes saved successfully!")??"Changes saved successfully!"}"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }
  /// Deletes a specific airplane from the Airdatabase.
  Future<void> _deleteAirplane(Airplane airplanes) async {
    await _database!.airplaneDao.deleteAirplane(airplanes);
    setState(() {
      if (_selectedList?.id == airplanes.id) {
        _selectedList = null;
      }
    });
    await _loadAirplanesFromDb();
  }
  /// Handles selection of an airplane from the list.
  void _onAirplaneSelected(Airplane airplanes) {
    setState(() {
      _selectedList = airplanes;
      _typeController.text = airplanes.type;
      _passengerCountController.text = airplanes.passengerCount.toString();
      _maxSpeedController.text = airplanes.maxSpeed.toString();
      _rangeController.text = airplanes.range.toString();
    });
  }
  @override
  void dispose() {
    _typeController.dispose();
    _passengerCountController.dispose();
    _maxSpeedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }
  /// Navigates to the airplane detail page to add a new airplane.
  void _navigateToAdd() async {
    if(_database == null) return; //数据库初始化
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AirplaneDetailPage(
        database: _database!,
      locale: widget.locale,
      onLanguageChanged: widget.onLanguageChanged)),
    );
    if (result == true) {
      _loadAirplanesFromDb();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text("${AppLocalizations.of(context)!.translate('Airplane added!')??"Airplane added!"}"),
      ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_database == null){
      return Scaffold(
        appBar: AppBar(title: Text("${AppLocalizations.of(context)!.translate('Loading...')??'Loading...'}"),),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFF0FFFF),
      appBar: AppBar(

        title: Text("${AppLocalizations.of(context)!.translate('Airplane List')??"Airplane List"}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title:
                  Text("${AppLocalizations.of(context)!.translate('Instructions')??"Instructions"}"),
                  content:
                  Text("${AppLocalizations.of(context)!.translate('Use the + button to add airplanes.\nTap an airplane to edit or delete it.')??'Use the + button to add airplanes.\nTap an airplane to edit or delete it.'}"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child:
                  Text("${AppLocalizations.of(context)!.translate('OK')}"),)
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/sky.jpg'),
        fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
          Colors.white.withOpacity(0.5),
          BlendMode.dstATop,
        ),
        ),
        ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                ),
                Expanded(
                  child: airplanes.isEmpty
                      ? Center(child:
                  Text("${AppLocalizations.of(context)!.translate('No airplane yet')??"No airplane yet"}"),)
                      : ListView.builder(
                    itemCount: airplanes.length,
                    itemBuilder: (context, index) {
                      final airplane = airplanes[index];
                      return ListTile(
                        title: Text(airplane.type,
                        style:TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ],
                        ),
                        ),
                        onTap: () {
                          _onAirplaneSelected(airplane);
                        },
                        selected: _selectedList?.id == airplane.id,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _selectedList == null
                ? Center(child:
                Text("${AppLocalizations.of(context)!.translate('Select an airplane to view/edit.')??"Select an airplane to view/edit."}"),
            )
                : _buildDetailEditor(),
          ),
        ],
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: Icon(Icons.add),
      ),
    );
  }
  /// Builds the editor for selected airplane details.
  Widget _buildDetailEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText:
                AppLocalizations.of(context)!.translate('Type'),
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 \-]')),
              ],
          style: TextStyle(fontSize: 18),
              ),
            TextField(
              controller: _passengerCountController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('Passenger Count'),
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxSpeedController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('Max Speed'),
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rangeController,
              decoration: InputDecoration(labelText:
              AppLocalizations.of(context)!.translate('Range'),
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: (){
                  _showConfirmSaveDialog();
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white),
                  child:
                  Text("${AppLocalizations.of(context)!.translate('Update')}"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _deleteAirplane(_selectedList!);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red),
                  child:
                  Text("${AppLocalizations.of(context)!.translate('Delete')}"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  /// Shows a confirmation dialog before saving changes.
  void _showConfirmSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
          Text("${AppLocalizations.of(context)!.translate('Confirm Save')}"),
          content:
          Text("${AppLocalizations.of(context)!.translate('Are you sure you want to save changes to this airplane?.')??"Are you sure you want to save changes to this airplane?"}"),
          actions: <Widget>[
            TextButton(
              child:
              Text("${AppLocalizations.of(context)!.translate('Save')}"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _editAirplane();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            TextButton(
              child:
              Text("${AppLocalizations.of(context)!.translate('Cancel')}"),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }
  }
