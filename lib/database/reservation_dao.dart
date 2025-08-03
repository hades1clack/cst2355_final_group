import 'package:floor/floor.dart';
import 'reservation.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM reservations')
  Future<List<Reservation>> findAllReservations();

  @insert
  Future<void> insertReservation(Reservation reservation);

  @update
  Future<void> updateReservation(Reservation reservation);

  @delete
  Future<void> deleteReservation(Reservation reservation);
}
