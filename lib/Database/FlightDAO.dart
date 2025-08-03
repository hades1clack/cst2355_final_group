import 'package:floor/floor.dart';
import 'Flights.dart';

/// DAO for managing flights in the database.
@dao
abstract class FlightDAO{

  ///create a Query function to get the objects:
  @Query("SELECT * FROM Flights")
  Future<List<Flights>> getAllFlight();

  // @Query("SELECT * FROM flights WHERE flightNumber = :flightNumber")
  // Future<Flights> getFlightByNumber(int flightNumber);
  
  ///@insert adds a new flight to the database
  @insert
  Future<void> addFlights( Flights toBeInserted );

  ///@delete a flight from the database
  @delete
  Future<void> deleteFlights( Flights toBeDeleted );

  ///@update a flight. The flightNumber must match an existing flight.
  @update
  Future<void> updateFlights( Flights newFlight );

}