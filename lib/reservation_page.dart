import 'package:flutter/material.dart';
import 'database/reservation.dart'; // Importing the Reservation entity
import 'database/reservation_database.dart'; // Importing the database class
import 'database/reservation_dao.dart'; // Importing the DAO interface
import 'add_reservation_page.dart'; // Page to add new reservations
import 'localization/AppLocalizations.dart'; // Localization helper
import 'main.dart'; // Main app entry for setting locale

/// Main page that displays a list of reservations and allows adding/deleting them.
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late ReservationDatabase db; // Database instance
  late ReservationDao dao; // Data Access Object to perform DB operations

  List<Reservation> _reservations = []; // List of all reservations

  @override
  void initState() {
    super.initState();
    initDatabase(); // Initialize DB when widget loads
  }

  /// Initializes the Floor database and gets the DAO
  Future<void> initDatabase() async {
    db = await $FloorReservationDatabase
        .databaseBuilder('reservations.db')
        .build(); // Build database
    dao = db.reservationDao; // Get the DAO
    _refreshReservations(); // Load existing reservations
  }

  /// Loads all reservations from the DB and updates the state
  void _refreshReservations() async {
    final list = await dao.findAllReservations();
    setState(() {
      _reservations = list;
    });
  }

  /// Shows reservation details in a dialog with delete option
  void _showReservationDetails(Reservation r) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(r.reservationName),
            content: Text(
              "${loc.translate('customer_id')}: ${r.customerId}\n"
                  "${loc.translate('flight_id')}: ${r.flightId}\n"
                  "${loc.translate('flight_date')}: ${r.flightDate}",
            ),
            actions: [
              // Delete reservation
              TextButton(
                onPressed: () async {
                  await dao.deleteReservation(r);
                  Navigator.pop(context); // Close dialog
                  _refreshReservations(); // Refresh list
                },
                child: Text(loc.translate('delete')!),
              ),
              // Close dialog
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.translate('close')!),
              ),
            ],
          ),
    );
  }

  /// Navigates to AddReservationPage and refreshes list if new reservation is added
  Future<void> _navigateToAddReservation() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddReservationPage(database: db),
      ),
    );
    if (added == true) {
      _refreshReservations(); // Refresh list if new reservation was added
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate("title")!), // Localized title
        actions: [
          TextButton(
            onPressed: () => MyApp.setLocale(context, const Locale("en", "US")),
            child: const Text("EN", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => MyApp.setLocale(context, const Locale("fr", "FR")),
            child: const Text("FR", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),

      //  Add background image here
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/sky.jpg'),
            // 🔹 Make sure this file exists in assets
            fit: BoxFit.cover,
            // 🔹 Cover full background
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              // 🔹 Make it slightly faded for readability
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _navigateToAddReservation,
              child: Text(loc.translate("add_reservation")!),
            ),
            const Divider(),
            Text(
              loc.translate("title")!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final r = _reservations[index];
                  return ListTile(
                    title: Text(r.reservationName),
                    subtitle: Text(
                      "${loc.translate('customer_id')}: ${r.customerId}, "
                          "${loc.translate('flight_id')}: ${r.flightId}",
                    ),
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
