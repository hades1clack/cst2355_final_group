import 'package:flutter/material.dart';
import 'database/reservation.dart';
import 'database/reservation_database.dart';
import 'database/reservation_dao.dart';
import 'add_reservation_page.dart';
import 'localization/AppLocalizations.dart';
import 'dev_main.dart';

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
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(r.reservationName),
        content: Text(
            "${loc.translate('customer_id')}: ${r.customerId}\n"
                "${loc.translate('flight_id')}: ${r.flightId}\n"
                "${loc.translate('flight_date')}: ${r.flightDate}"
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dao.deleteReservation(r);
              Navigator.pop(context);
              _refreshReservations();
            },
            child: Text(loc.translate('delete')!),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('close')!),
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate("title")!),
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
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToAddReservation,
            child: Text(loc.translate("add_reservation")!),
          ),
          const Divider(),
          Text(loc.translate("title")!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final r = _reservations[index];
                return ListTile(
                  title: Text(r.reservationName),
                  subtitle: Text("${loc.translate('customer_id')}: ${r.customerId}, ${loc.translate('flight_id')}: ${r.flightId}"),
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
