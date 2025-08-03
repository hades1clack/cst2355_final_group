import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'database/reservation.dart';
import 'database/reservation_database.dart';
import 'localization/AppLocalizations.dart'; // Import localization

class AddReservationPage extends StatefulWidget {
  final ReservationDatabase database;

  const AddReservationPage({super.key, required this.database});

  @override
  State<AddReservationPage> createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  late final dao;

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _flightIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    dao = widget.database.reservationDao;
  }

  Future<void> _copyPreviousCustomerFields() async {
    try {
      _customerIdController.text = await _prefs.getString('customerId') ?? '';
      _flightIdController.text = await _prefs.getString('flightId') ?? '';
      _dateController.text = await _prefs.getString('flightDate') ?? '';
      _nameController.text = await _prefs.getString('reservationName') ?? '';
    } catch (_) {}
  }

  Future<void> _saveEncryptedPrefs() async {
    await _prefs.setString('customerId', _customerIdController.text);
    await _prefs.setString('flightId', _flightIdController.text);
    await _prefs.setString('flightDate', _dateController.text);
    await _prefs.setString('reservationName', _nameController.text);
  }

  void _addReservation() async {
    final loc = AppLocalizations.of(context)!;
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

    final reservation = Reservation(
      customerId: _customerIdController.text,
      flightId: _flightIdController.text,
      flightDate: _dateController.text,
      reservationName: _nameController.text,
    );

    await dao.insertReservation(reservation);
    await _saveEncryptedPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate("reservation_added") ?? "Reservation added successfully")),
    );

    Navigator.pop(context, true); // return true to indicate added
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate("add_reservation") ?? "Add Reservation")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(labelText: loc.translate("customer_id") ?? "Customer ID"),
            ),
            TextField(
              controller: _flightIdController,
              decoration: InputDecoration(labelText: loc.translate("flight_id") ?? "Flight ID"),
            ),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: loc.translate("flight_date") ?? "Flight Date (YYYY-MM-DD)"),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: loc.translate("reservation_name") ?? "Reservation Name"),
            ),
            const SizedBox(height: 20),
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
    );
  }
}
