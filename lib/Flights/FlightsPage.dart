import 'package:cst2355_final_group/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:cst2355_final_group/Database/FlightDAO.dart';
import 'package:cst2355_final_group/Database/Flights.dart';
import 'package:cst2355_final_group/Flights/FlightAddingPage.dart';
import 'package:cst2355_final_group/main.dart';


/// FlightsPage displays the list of flights and allows adding, updating or deleting them.
/// Displays a message if no flight exists and navigates to FlightsAddingPage to add a new flight.
class FlightsPage extends StatefulWidget {
  ///Declares Flight's local database instance
  final FlightDAO flightDAO;

  const FlightsPage({super.key, required this.flightDAO});

  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  ///Creates an empty array
  List<Flights> _flights = [];

  ///The selected flight for editing
  Flights? _selectedFlight;

  ///Form key for validation
  final _formKey = GlobalKey<FormState>();

  ///Controllers for the flight detail form fields
  final _flightNumberController = TextEditingController();
  final _departureCityController = TextEditingController();
  final _destinationCityController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _arrivalTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadFlights();
  }

  ///Loads flights from database
  Future<void> loadFlights() async {
    final flights = await widget.flightDAO.getAllFlight();

    setState(() {
      _flights = flights;
      _selectedFlight = null;

      /// If the flight selected is not null, always the latest version displayed.
      /// else displayed null.
      if (_selectedFlight != null) {
        final updated = flights.where((f) => f.flightNumber == _selectedFlight!.flightNumber);
        _selectedFlight = updated.isNotEmpty ? updated.first : null;
      }
    });
  }

  ///displays the selected flight when user selects a flight from the list.
  void _handleFlightTap(Flights flight) {
    setState(() {
      _selectedFlight = flight;
      _flightNumberController.text = flight.flightNumber;
      _departureCityController.text = flight.departureCity;
      _destinationCityController.text = flight.destinationCity;
      _departureTimeController.text = flight.departureTime;
      _arrivalTimeController.text = flight.arrivalTime;
    });
  }

  /// Updates the selected flight with edited values in the database
  Future<void> _updateFlight() async {
    if (_selectedFlight == null || !_formKey.currentState!.validate()) return;

    final updatedFlight = Flights(
      id: _selectedFlight!.id,
      flightNumber: _flightNumberController.text.trim(),
      departureCity: _departureCityController.text.trim(),
      destinationCity: _destinationCityController.text.trim(),
      departureTime: _departureTimeController.text.trim(),
      arrivalTime: _arrivalTimeController.text.trim(),
    );

    await widget.flightDAO.updateFlights(updatedFlight);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.translate("flightUpdated")!),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
      ),
    );
    await loadFlights();
  }

  ///controls over when to refresh the list — only if a flight was truly added.
  // Future<void> _navigateToAddFlight() async {
  //   final result = await Navigator.push<bool>(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => FlightAddingPage(flightDAO: widget.flightDAO),
  //     ),
  //   );

  //   if (result == true) {
  //     await loadFlights();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(AppLocalizations.of(context)!.translate("flightAdded")!),
  //         duration: Duration(seconds: 3),
  //         behavior: SnackBarBehavior.fixed,
  //       ),
  //     );
  //   }
  // }

  /// Deletes the selected flight from database
  Future<void> _deleteFlight(Flights flight) async {
    await widget.flightDAO.deleteFlights(_selectedFlight!);

    /// only clear selection if the deleted flight was currently selected.
    setState(() {
      if (_selectedFlight?.flightNumber == flight.flightNumber) {
        _selectedFlight = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.translate("flightDeleted")!),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.fixed,
      ),
    );
    await loadFlights();
  }

  @override
  void dispose() {
    _flightNumberController.dispose();
    _departureCityController.dispose();
    _destinationCityController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  /// Changes the locale of Flights pages. Calling this method in main app widget.
  void _changeLanguage(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<MyAppState>();
    state?.changeLanguage(locale);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFlights = _flights.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('flights')!),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              _changeLanguage(context, locale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('fr'), child: Text('Français')),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: hasFlights
                      ? ListView.builder(
                    itemCount: _flights.length,
                    itemBuilder: (context, index) {
                      final flight = _flights[index];
                      return ListTile(
                        title: Text(flight.flightNumber),
                        subtitle: Text('${flight.departureCity} → ${flight.destinationCity}'),
                        onTap: () => _handleFlightTap(flight),
                        selected: _selectedFlight?.id == flight.id,
                      );
                    },
                  )
                      : Center(
                    child: Text(AppLocalizations.of(context)!.translate('noFlights')!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.translate('addFlight')!),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlightAddingPage(flightDAO: widget.flightDAO),
                        ),
                      );
                      loadFlights();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _selectedFlight == null
                ? Center(
              child: Text(AppLocalizations.of(context)!.translate('selectFlight')!),
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _flightNumberController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('flightNumber'),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.translate('requiredField')
                          : null,
                    ),
                    TextFormField(
                      controller: _departureCityController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('departureCity'),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.translate('requiredField')
                          : null,
                    ),
                    TextFormField(
                      controller: _destinationCityController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('arrivalCity'),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.translate('requiredField')
                          : null,
                    ),
                    TextFormField(
                      controller: _departureTimeController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('departureTime'),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.translate('requiredField')
                          : null,
                    ),
                    TextFormField(
                      controller: _arrivalTimeController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.translate('arrivalTime'),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppLocalizations.of(context)!.translate('requiredField')
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _updateFlight,
                      child: Text(AppLocalizations.of(context)!.translate('updateFlight')!),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _selectedFlight == null
                          ? null
                          : () => _deleteFlight(_selectedFlight!),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(AppLocalizations.of(context)!.translate('deleteFlight')!),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// An interface that your main app widget must implement to allow locale changes.
abstract class LocaleUpdater {
  void setLocale(Locale locale);
}
