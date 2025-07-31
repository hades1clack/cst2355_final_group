import 'package:floor/floor.dart';

@Entity(tableName: 'Customer')
class Customer{
  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String birthDate;

  static int ID=1;
  Customer(this.id, this.firstName,this.lastName,this.birthDate,this.address){
    if(id>=ID){
      ID=id+1;
    }

  }

}