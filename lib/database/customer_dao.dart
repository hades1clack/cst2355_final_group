import 'package:floor/floor.dart';
import 'customer.dart';

@dao
abstract class CustomerDao{
  @Query('select * from Customer')
  Future<List<Customer>> findAll();

  @insert
  Future<void> insertCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);

}