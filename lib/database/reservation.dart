import 'package:floor/floor.dart';

@Entity(tableName: 'reservations')
class Reservation {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String customerId;
  final String flightId;
  final String flightDate;
  final String reservationName;

  Reservation({this.id, required this.customerId, required this.flightId, required this.flightDate, required this.reservationName});
}
