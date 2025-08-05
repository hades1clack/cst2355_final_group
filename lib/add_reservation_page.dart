import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'database/reservation.dart';
import 'database/reservation_database.dart';
import 'localization/AppLocalizations.dart'; // Import localization

/// Page for adding a new reservation with fields and encrypted shared preferences.
class AddReservationPage extends StatefulWidget {
  /// The database instance used to perform reservation data operations.
  final ReservationDatabase database;
  /// Creates an AddReservationPage with the required database.
  const AddReservationPage({super.key, required this.database});

  @override
  State<AddReservationPage> createState() => _AddReservationPageState();
}
/// Manages form input, controls text editing, and interacts with the reservation DAO.
class _AddReservationPageState extends State<AddReservationPage> {
  /// Data Access Object for reservation operations, initialized from [widget.database].
  late final dao;
  // Text controllers for input fields
  final TextEditingController _customerIdController = TextEditingController();
  /// Controller for the Flight ID input field.
  final TextEditingController _flightIdController = TextEditingController();
  /// Controller for the Date input field.
  final TextEditingController _dateController = TextEditingController();
  /// Controller for the Reservation Name input field.
  final TextEditingController _nameController = TextEditingController();

  // Encrypted Shared Preferences instance to store last entered values securely
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    dao = widget.database.reservationDao; // Initialize DAO from passed database
  }

  /// Copies previously saved customer info from encrypted preferences into text fields
  Future<void> _copyPreviousCustomerFields() async {
    try {
      _customerIdController.text = await _prefs.getString('customerId') ?? '';
      _flightIdController.text = await _prefs.getString('flightId') ?? '';
      _dateController.text = await _prefs.getString('flightDate') ?? '';
      _nameController.text = await _prefs.getString('reservationName') ?? '';
    } catch (_) {
      // If an error occurs (e.g. no stored values), do nothing
    }
  }

  /// Saves current inputs securely in encrypted shared preferences
  Future<void> _saveEncryptedPrefs() async {
    await _prefs.setString('customerId', _customerIdController.text);
    await _prefs.setString('flightId', _flightIdController.text);
    await _prefs.setString('flightDate', _dateController.text);
    await _prefs.setString('reservationName', _nameController.text);
  }

  /// Validates input, inserts new reservation, saves prefs, shows confirmation, and closes page
  void _addReservation() async {
    final loc = AppLocalizations.of(context)!;

    // Check for empty fields and show alert if any are missing
    if (_customerIdController.text.isEmpty ||
        _flightIdController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(loc.translate("missing_fields") ?? "Missing fields"),
          content: Text(loc.translate("please_fill") ?? "Please fill all fields"),
        ),
      );
      return;
    }

    // Create a new Reservation object with input data
    final reservation = Reservation(
      customerId: _customerIdController.text,
      flightId: _flightIdController.text,
      flightDate: _dateController.text,
      reservationName: _nameController.text,
    );

    await dao.insertReservation(reservation); // Insert into database
    await _saveEncryptedPrefs(); // Save inputs to encrypted prefs

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate("reservation_added") ?? "Reservation added successfully")),
    );

    Navigator.pop(context, true); // Close page and notify success
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate("add_reservation") ?? "Add Reservation")),

      // Add a background image using a Container with BoxDecoration
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sky.jpg'),  // <-- Your sky image in assets folder
            fit: BoxFit.cover,                     // Cover the entire background
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),      // Slightly faded white overlay for readability
              BlendMode.dstATop,
            ),
          ),
        ),

        // The actual form inputs and buttons go inside a Padding + ListView for scrollability
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              // Customer ID input field
              TextField(
                controller: _customerIdController,
                decoration: InputDecoration(labelText: loc.translate("customer_id") ?? "Customer ID"),
              ),
              // Flight ID input field
              TextField(
                controller: _flightIdController,
                decoration: InputDecoration(labelText: loc.translate("flight_id") ?? "Flight ID"),
              ),
              // Flight date input field
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: loc.translate("flight_date") ?? "Flight Date (YYYY-MM-DD)"),
              ),
              // Reservation name input field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: loc.translate("reservation_name") ?? "Reservation Name"),
              ),
              const SizedBox(height: 20),

              // Buttons row for submitting or copying previous data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addReservation,
                    child: Text(loc.translate("submit") ?? "Add"),
                  ),
                  ElevatedButton(
                    onPressed: _copyPreviousCustomerFields,
                    child: Text(loc.translate("copy_previous") ?? "Copy Previous Customer"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
