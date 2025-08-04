import 'package:floor/floor.dart';
import 'customer.dart';

@dao
abstract class CustomerDao{
  @Query('select * from Customer')
  Future<List<Customer>> findAll();

  @insert
  Future<int> insertCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);
}