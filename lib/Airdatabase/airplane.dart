import 'package:floor/floor.dart';

@Entity()
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String type;
  final int passengerCount;
  final double maxSpeed;
  final double range;

  Airplane({
    this.id,
    required this.type,
    required this.passengerCount,
    required this.maxSpeed,
    required this.range,
  });
}