import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'database/reservation.dart';
import 'database/reservation_database.dart';
import 'database/reservation_dao.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late ReservationDatabase db;
  late ReservationDao dao;

  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _flightIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<Reservation> _reservations = [];
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    db = await $FloorReservationDatabase.databaseBuilder('reservations.db').build();
    dao = db.reservationDao;
    _refreshReservations();
  }

  Future<void> _copyPreviousCustomerFields() async {
    try {
      _customerIdController.text = await _prefs.getString('customerId') ?? '';
      _flightIdController.text = await _prefs.getString('flightId') ?? '';
      _dateController.text = await _prefs.getString('flightDate') ?? '';
      _nameController.text = await _prefs.getString('reservationName') ?? '';
    } catch (_) {
      // Handle decryption error if any
    }
  }

  Future<void> _saveEncryptedPrefs() async {
    await _prefs.setString('customerId', _customerIdController.text);
    await _prefs.setString('flightId', _flightIdController.text);
    await _prefs.setString('flightDate', _dateController.text);
    await _prefs.setString('reservationName', _nameController.text);
  }

  void _refreshReservations() async {
    final list = await dao.findAllReservations();
    setState(() {
      _reservations = list;
    });
  }

  void _addReservation() async {
    if (_customerIdController.text.isEmpty ||
        _flightIdController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Missing fields"),
          content: Text("Please fill all fields"),
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
    _refreshReservations();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reservation added successfully")),
    );
  }

  void _deleteReservation(Reservation reservation) async {
    await dao.deleteReservation(reservation);
    _refreshReservations();
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Instructions"),
        content: Text(
          "Enter a Customer ID, Flight ID, Flight Date, and Reservation Name.\nTap 'Add Reservation' to save it.\n\nTap 'Copy Previous Customer' to reuse the last added customer info.",
        ),
      ),
    );
  }

  void _showReservationDetails(Reservation r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r.reservationName),
        content: Text(
            "Customer ID: ${r.customerId}\n"
                "Flight ID: ${r.flightId}\n"
                "Flight Date: ${r.flightDate}"
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReservation(r);
            },
            child: const Text("Delete"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation Page"),
        actions: [
          IconButton(icon: const Icon(Icons.info_outline), onPressed: _showInstructions),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _customerIdController,
              decoration: const InputDecoration(labelText: "Customer ID"),
            ),
            TextField(
              controller: _flightIdController,
              decoration: const InputDecoration(labelText: "Flight ID"),
            ),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Flight Date (YYYY-MM-DD)"),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Reservation Name"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addReservation,
                  child: const Text("Add Reservation"),
                ),
                ElevatedButton(
                  onPressed: _copyPreviousCustomerFields,
                  child: const Text("Copy Previous Customer"),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(),
            const Text("All Reservations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final r = _reservations[index];
                  return ListTile(
                    title: Text(r.reservationName),
                    subtitle: Text("Customer ID: ${r.customerId}, Flight ID: ${r.flightId}"),
                    onTap: () => _showReservationDetails(r),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
