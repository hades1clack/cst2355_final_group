import 'dart:async'; // For using Future and async operations
import 'package:floor/floor.dart'; // Floor ORM package
import 'package:sqflite/sqflite.dart' as sqflite; // Underlying SQLite package
import 'reservation.dart'; // Reservation entity
import 'reservation_dao.dart'; // DAO for Reservation operations

// This line is needed by Floor. The generated code will be saved in this file.
// You must run the build runner command to generate it:
// flutter packages pub run build_runner build
part 'reservation_database.g.dart';

/// This annotation tells Floor to create a database class with:
/// - version 1 (change this number when upgrading the schema)
/// - one table, which is the Reservation entity
@Database(version: 1, entities: [Reservation])
abstract class ReservationDatabase extends FloorDatabase {
  /// This provides access to the ReservationDao, which contains all database methods
  ReservationDao get reservationDao;
}
