import 'package:flutter/material.dart';
import 'package:cst2355_final_group/database/app_database.dart';
import 'package:cst2355_final_group/database/airplane.dart';
import 'package:cst2355_final_group/pages/airplane_detail_page.dart';
import 'package:flutter/services.dart';
/// Entry point of the app.
/// Initializes the database and launches the application.
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}
/// Root widget of the app.
class MyApp extends StatelessWidget {
  /// The database instance passed into the app.
  final AppDatabase database;
  MyApp(this.database, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airplane List Page Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: AirplaneListPage(database: database),
    );
  }
}
/// Main page displaying the list of airplanes.
class AirplaneListPage extends StatefulWidget {
  /// The database instance used to retrieve airplane data.
  final AppDatabase database;
  const AirplaneListPage({Key? key, required this.database}) : super(key: key);

  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  /// Controller for the airplane type input field.
  final TextEditingController _typeController = TextEditingController();
  /// Controller for the passenger count input field.
  final TextEditingController _passengerCountController = TextEditingController();
  /// Controller for the maximum speed input field.
  final TextEditingController _maxSpeedController = TextEditingController();
  /// Controller for the range input field.
  final TextEditingController _rangeController = TextEditingController();
  /// List of airplanes fetched from the database.
  List<Airplane> airplanes = [];
  /// Currently selected airplane from the list.
  Airplane? _selectedList;

  @override
  void initState() {
    super.initState();
    _loadAirplanesFromDb();
  }
  /// Loads all airplane records from the database.
  Future<void> _loadAirplanesFromDb() async {
    final list = await widget.database.airplaneDao.getAllAirplanes();
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

      await widget.database.airplaneDao.updateAirplane(newAirplane);

      _typeController.clear();
      _passengerCountController.clear();
      _maxSpeedController.clear();
      _rangeController.clear();

      await _loadAirplanesFromDb();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }
  /// Deletes a specific airplane from the database.
  Future<void> _deleteAirplane(Airplane airplanes) async {
    await widget.database.airplaneDao.deleteAirplane(airplanes);
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
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AirplaneDetailPage(database: widget.database)),
    );
    if (result == true) {
      _loadAirplanesFromDb();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FFFF),
      appBar: AppBar(
        title: const Text('Airplane List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text(
                      'Use the + button to add airplanes.\nTap an airplane to edit or delete it.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
        image: AssetImage('assets/images/sky.jpg'),
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
                      ? Center(child: Text('No airplanes yet.'))
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
                ? Center(child: Text('Select an airplane to view/edit.'))
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
              decoration: InputDecoration(labelText: 'Type',
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 \-]')),
              ],
          style: TextStyle(fontSize: 18),
              ),
            TextField(
              controller: _passengerCountController,
              decoration: InputDecoration(labelText: 'Passenger Count',
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxSpeedController,
              decoration: InputDecoration(labelText: 'Max Speed',
                labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rangeController,
              decoration: InputDecoration(labelText: 'Range',
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
                  child: const Text('Update'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _deleteAirplane(_selectedList!);
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red),
                  child: const Text('Delete'),
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
          title: const Text('Confirm Save'),
          content: const Text('Are you sure you want to save changes to this airplane?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
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
              child: const Text('Cancel'),
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
