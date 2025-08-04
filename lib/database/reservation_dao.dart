import 'package:floor/floor.dart';
import 'reservation.dart';

/// This annotation tells Floor that this class is a Data Access Object (DAO)
/// for performing operations on the 'reservations' table.
@dao
abstract class ReservationDao {
  /// Retrieves all records from the 'reservations' table.
  /// Returns a list of Reservation objects.
  @Query('SELECT * FROM reservations')
  Future<List<Reservation>> findAllReservations();

  /// Inserts a new reservation into the database.
  /// If there's a conflict (e.g., same primary key), Floor will throw an error by default.
  @insert
  Future<void> insertReservation(Reservation reservation);

  /// Updates an existing reservation record in the database.
  /// The object must have a matching primary key in the table.
  @update
  Future<void> updateReservation(Reservation reservation);

  /// Deletes the specified reservation from the database.
  /// The object must match a record in the table based on its primary key.
  @delete
  Future<void> deleteReservation(Reservation reservation);
}
