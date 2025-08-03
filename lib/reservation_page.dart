import 'package:flutter/material.dart';
import 'database/reservation.dart';
import 'database/reservation_database.dart';
import 'database/reservation_dao.dart';
import 'add_reservation_page.dart'; // We'll create this next

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late ReservationDatabase db;
  late ReservationDao dao;

  List<Reservation> _reservations = [];

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

  void _refreshReservations() async {
    final list = await dao.findAllReservations();
    setState(() {
      _reservations = list;
    });
  }

  void _showReservationDetails(Reservation r) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r.reservationName),
        content: Text(
            "Customer ID: ${r.customerId}\n"
                "Flight ID: ${r.flightId}\n"
                "Flight Date: ${r.flightDate}"),
        actions: [
          TextButton(
            onPressed: () async {
              await dao.deleteReservation(r);
              Navigator.pop(context);
              _refreshReservations();
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

  Future<void> _navigateToAddReservation() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddReservationPage(database: db),
      ),
    );
    if (added == true) {
      _refreshReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservations"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToAddReservation,
            child: const Text("Add Reservation"),
          ),
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
    );
  }
}
