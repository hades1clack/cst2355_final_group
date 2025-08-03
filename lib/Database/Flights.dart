///entity/Flights.dart

import 'package:floor/floor.dart';


/// Flights entity stores detailed information on flights in the local database.
/// Tells Floor to create a Table called Flights
@entity
class Flights {
  /// Tells Floor that this is unique key that provided by user.
  @primaryKey
  final int? id;

  final String flightNumber;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  /// Constructs a Flights.
  Flights({
    this.id,
    required this.flightNumber,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,

  });

}