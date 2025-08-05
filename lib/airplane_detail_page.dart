
import 'package:flutter/material.dart';
import 'package:cst2355_final_group/Airdatabase/app_database.dart';
import 'package:cst2355_final_group/Airdatabase/airplane.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cst2355_final_group/localization/AppLocalizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Airplane detail page used for adding or editing airplane information.
/// Supports input for airplane type, passenger count, max speed and range.
class AirplaneDetailPage extends StatefulWidget {
  /// The Airdatabase instance used for airplane data operations.
  final AppDatabase database;
  /// The airplane being edited; null indicates adding a new airplane.
  final Airplane? airplane;
  /// Constructor accepting the Airdatabase and optionally an existing airplane to edit.
  final Locale locale;
  final void Function(Locale) onLanguageChanged;

  const AirplaneDetailPage({
    Key? key,
    required this.database,
    this.airplane,
    required this.locale,
    required this.onLanguageChanged,
  }) : super(key: key);
  @override
  _AirplaneDetailPageState createState() => _AirplaneDetailPageState();
}

class _AirplaneDetailPageState extends State<AirplaneDetailPage> {
  /// Global key for the form to validate input fields.
  final _formKey = GlobalKey<FormState>();
  /// Controller for the airplane type input field.
  late TextEditingController _typeController;
  /// Controller for the passenger count input field.
  late TextEditingController _passengersController;
  /// Controller for the max speed input field.
  late TextEditingController _maxSpeedController;
  /// Controller for the range input field.
  late TextEditingController _rangeController;
  /// Secure storage to save and load last input values for convenience.
  final _secureStorage = const FlutterSecureStorage();
  /// Controller for the max speed input field.
  bool get isEditMode => widget.airplane != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing airplane data if editing,
    // or empty strings if adding a new airplane.
    _typeController = TextEditingController(text: widget.airplane?.type ?? '');
    _passengersController = TextEditingController(text: widget.airplane?.passengerCount.toString() ?? '');
    _maxSpeedController = TextEditingController(text: widget.airplane?.maxSpeed.toString() ?? '');
    _rangeController = TextEditingController(text: widget.airplane?.range.toString() ?? '');
    // Load last saved input values from secure storage when adding new airplane.
    if (!isEditMode) {
      _loadLastInput();
    }
  }

  /// Loads the last input values from secure storage and populates the fields.
  Future<void> _loadLastInput() async {
    _typeController.text = await _secureStorage.read(key: 'type') ?? '';
    _passengersController.text = await _secureStorage.read(key: 'passengerCount') ?? '';
    _maxSpeedController.text = await _secureStorage.read(key: 'maxSpeed') ?? '';
    _rangeController.text = await _secureStorage.read(key: 'range') ?? '';
  }

  @override
  void dispose() {
    _typeController.dispose();
    _passengersController.dispose();
    _maxSpeedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }
  /// Validates input and saves airplane data to the Airdatabase.
  /// If editing, updates existing airplane; otherwise inserts new.
  /// Also saves current inputs to secure storage for future reuse.
  Future<void> _saveAirplane() async {
    if (!_formKey.currentState!.validate()) return;

    final type = _typeController.text.trim();
    final passengers = int.parse(_passengersController.text.trim());
    final maxSpeed = double.parse(_maxSpeedController.text.trim());
    final range = double.parse(_rangeController.text.trim());

    final airplane = Airplane(
      id: widget.airplane?.id,
      type: type,
      passengerCount: passengers,
      maxSpeed: maxSpeed,
      range: range,
    );

    if (isEditMode) {
      await widget.database.airplaneDao.updateAirplane(airplane);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:
        Text("${AppLocalizations.of(context)!.translate('Airplane updated')}"),
       ),
      );
    } else {
      await widget.database.airplaneDao.insertAirplane(airplane);
    }
    // Save current inputs securely for next time when adding new.
    await _secureStorage.write(key: 'type', value: type);
    await _secureStorage.write(key: 'passengerCount', value: passengers.toString());
    await _secureStorage.write(key: 'maxSpeed', value: maxSpeed.toString());
    await _secureStorage.write(key: 'range', value: range.toString());
    // Close this page and signal successful save with true.
    Navigator.pop(context, true);
  }

  /// Prompts user for confirmation and deletes the current airplane if confirmed.
  Future<void> _deleteAirplane() async {
    if (!isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:
        Text("${AppLocalizations.of(context)!.translate('Confirm Delete')}"),
        content: Text('Delete airplane "${widget.airplane!.type}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child:
          Text("${AppLocalizations.of(context)!.translate('No')}"),
          ),

          TextButton(onPressed: () => Navigator.pop(context, true), child:
          Text("${AppLocalizations.of(context)!.translate('Yes')}"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.database.airplaneDao.deleteAirplane(widget.airplane!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${AppLocalizations.of(context)!.translate('Airplane deleted')}"),
      ),);
      Navigator.pop(context, true);
    }
  }

  /// Builds a styled text form field with label, icon, validation, and keyboard type.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.lightBlue.shade700),
              border: InputBorder.none,
            ),
            keyboardType: keyboardType,
            validator: validator,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context)!.translate(isEditMode ? 'Edit Airplane' : 'Add Airplane')??'',),
        backgroundColor: Colors.lightBlue.shade700,

      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade200, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _typeController,
                    label: AppLocalizations.of(context)!.translate('airplane_type')??'Type',
                    icon: Icons.flight_takeoff,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return AppLocalizations.of(context)!.translate('enter_type_error');
                      final regex = RegExp(r'^[a-zA-Z0-9\s\-]+$');
                      if (!regex.hasMatch(value))
                        return AppLocalizations.of(context)!.translate('Only letters and numbers allowed');
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _passengersController,
                    label: AppLocalizations.of(context)!.translate('Passenger Count')??'Passenger Count',
                    icon: Icons.event_seat,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return AppLocalizations.of(context)!.translate('Please enter passenger count');
                      final number = double.tryParse(value);
                      if (number == null)
                        return AppLocalizations.of(context)!.translate('Must be a valid number');
                      if (number <= 0)
                        return AppLocalizations.of(context)!.translate('Must be greater than 0');
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _maxSpeedController,
                    label: AppLocalizations.of(context)!.translate('Max Speed(km/h)')??'Max Speed(km/h)',
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate('Please enter max speed');
                      final number = double.tryParse(value);
                      if (number == null) return AppLocalizations.of(context)!.translate('Must be a valid number');
                      if (number <= 0) return AppLocalizations.of(context)!.translate('Must be greater than 0');
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _rangeController,
                    label: AppLocalizations.of(context)!.translate('Range (km)')??'Range',
                    icon: Icons.route,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate('Please enter range');
                      final number = double.tryParse(value);
                      if (number == null) return AppLocalizations.of(context)!.translate('Must be a valid number');
                      if (number <= 0) return AppLocalizations.of(context)!.translate('Must be greater than 0');
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveAirplane,
                    icon: const Icon(Icons.add_circle),
                    label: Text(AppLocalizations.of(context)!.translate(isEditMode ? 'Update Airplane' : 'Add Airplane')??"Add"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlue.shade700,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: _deleteAirplane,
                        icon: const Icon(Icons.delete),
                        label: Text(AppLocalizations.of(context)!.translate('Delete Airplane')??"Delete Airplane"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade700,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
