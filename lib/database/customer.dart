import 'package:floor/floor.dart';

@Entity(tableName: 'Customer')
class Customer{
  @PrimaryKey(autoGenerate: true)
  final int? id;
  String firstName;
  String lastName;
  String address;
  String birthDate;

  Customer(
      this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.birthDate,
      );

}