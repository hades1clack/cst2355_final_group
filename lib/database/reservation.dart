import 'package:floor/floor.dart';

/// This annotation tells Floor to treat this class as a table named 'reservations'
@Entity(tableName: 'reservations')
class Reservation {
  /// The primary key for the 'reservations' table.
  /// `autoGenerate: true` means the ID will be generated automatically.
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /// ID of the customer making the reservation.
  final String customerId;

  /// ID of the flight the reservation is for.
  final String flightId;

  /// Date of the flight in a string format (e.g., '2025-08-04').
  final String flightDate;

  /// Name under which the reservation is made.
  final String reservationName;

  /// Constructor for creating a Reservation object.
  /// `id` is optional and will be auto-generated.
  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.flightDate,
    required this.reservationName,
  });
}
