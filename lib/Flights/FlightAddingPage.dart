import 'package:flutter/material.dart';
import 'package:cst2355_final_group/Database/FlightDAO.dart';
import 'package:cst2355_final_group/Database/Flights.dart';
import 'package:cst2355_final_group/localization/AppLocalizations.dart';
import 'package:cst2355_final_group/main.dart';

/// A page that allows the user to add a new flight record to the local database.
class FlightAddingPage extends StatefulWidget {
  /// Reference to the app's database.
  final FlightDAO flightDAO;

  /// Constructs a [FlightAddingPage] with the provided [FlightDAO].
  const FlightAddingPage({super.key, required this.flightDAO});

  @override
  State<FlightAddingPage> createState() => _FlightAddingPageState();
}

///Handles the form and logic
class _FlightAddingPageState extends State<FlightAddingPage> {
  /// Key to validate the form before submitting.
  final _formKey = GlobalKey<FormState>();

  /// Controllers for input fields.
  final _flightNumberController = TextEditingController();
  /// Controller for the departure city input field.
  final _departureCityController = TextEditingController();
  /// Controller for the destination city input field.
  final _destinationCityController = TextEditingController();
  /// Controller for the departure time input field.
  final _departureTimeController = TextEditingController();
  /// Controller for the arrival time input field.
  final _arrivalTimeController = TextEditingController();

  @override
  void dispose() {
    _flightNumberController.dispose();
    _departureCityController.dispose();
    _destinationCityController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  /// Submits the flight to the local database.
  /// Validates the form fields. If all fields are valid, the data is saved
  Future<void> _submitFlight() async {
    if (!_formKey.currentState!.validate()) return;

    final flight = Flights(
      id: null, // Let the database auto-generate ID.
      flightNumber: _flightNumberController.text.trim(),
      departureCity: _departureCityController.text.trim(),
      destinationCity: _destinationCityController.text.trim(),
      departureTime: _departureTimeController.text.trim(),
      arrivalTime: _arrivalTimeController.text.trim(),
    );

    await widget.flightDAO.addFlights(flight);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${AppLocalizations.of(context)!.translate('flightAdded')}"),
      ),
    );
    Navigator.pop(context, true);
  }

  /// Builds the UI for the adding flight form.
  /// Provides input fields for flight number, cities, and times, along with
  /// form validation and a submit button
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: Colors.lightBlue[40],
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.translate('addFlight')}"),
        actions: [
          /// Language selection menu in the AppBar.
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              final state = context.findAncestorStateOfType<MyAppState>();
              state?.changeLanguage(locale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: Locale('en'), child: Text('English')),
              PopupMenuItem(value: Locale('fr'), child: Text('Français')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// Input field for flight number.
              TextFormField(
                controller: _flightNumberController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('flightNumber'),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.translate('requiredField')
                    : null,
              ),
              /// Input field for departure city.
              TextFormField(
                controller: _departureCityController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('departureCity'),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.translate('requiredField')
                    : null,
              ),
              /// Input field for destination city.
              TextFormField(
                controller: _destinationCityController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('destinationCity'),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.translate('requiredField')
                    : null,
              ),
              /// Input field for departure time.
              TextFormField(
                controller: _departureTimeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('departureTime'),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.translate('requiredField')
                    : null,
              ),
              /// Input field for arrival time.
              TextFormField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('arrivalTime'),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? AppLocalizations.of(context)!.translate('requiredField')
                    : null,
              ),
              const SizedBox(height: 20),
              /// Submit button to save the flight.
              ElevatedButton(
                onPressed: _submitFlight,
                child: Text(AppLocalizations.of(context)!.translate('submit')!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
