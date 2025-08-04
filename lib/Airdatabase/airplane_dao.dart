import 'package:floor/floor.dart';
import 'airplane.dart';

@dao
abstract class AirplaneDao {
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();

  @Query('SELECT * FROM Airplane WHERE id = :id')
  Future<Airplane?> findAirplaneById(int id);

  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<void> deleteAirplane(Airplane airplane);
}