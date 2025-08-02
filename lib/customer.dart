// customer_page.dart
import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'database/customer.dart';
import 'database/customer_dao.dart';
import 'repository.dart'; // For EncryptedSharedPreferences logic

class CustomerPage extends StatefulWidget {
  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  List<Customer> customers = [];
  Customer? selectedCustomer;
  late AppDatabase database;
  late CustomerDao dao;

  @override
  void initState() {
    super.initState();
    initDatabase();
    _initRepository();
    _loadDataIntoFields();
  }

  Future<void> initDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('customer.db').build();
    dao = database.customerDao;
    customers = await dao.findAll();
    setState(() {});
  }

  Future<void> _initRepository() async {
    await DataRepository.loadData();
    firstNameController.text = DataRepository.firstName;
    lastNameController.text = DataRepository.lastName;
    addressController.text = DataRepository.address;
    birthDateController.text = DataRepository.birthDate;

    firstNameController.addListener(() {
      DataRepository.firstName = firstNameController.text;
      DataRepository.saveData();
    });
    lastNameController.addListener(() {
      DataRepository.lastName = lastNameController.text;
      DataRepository.saveData();
    });
    addressController.addListener(() {
      DataRepository.address = addressController.text;
      DataRepository.saveData();
    });
    birthDateController.addListener(() {
      DataRepository.birthDate = birthDateController.text;
      DataRepository.saveData();
    });
  }

  void _loadDataIntoFields() {
    if (selectedCustomer != null) {
      firstNameController.text = selectedCustomer!.firstName;
      lastNameController.text = selectedCustomer!.lastName;
      addressController.text = selectedCustomer!.address;
      birthDateController.text = selectedCustomer!.birthDate;
    }
  }

  Future<void> saveCustomer() async {
    final fName = firstNameController.text.trim();
    final lName = lastNameController.text.trim();
    final addr = addressController.text.trim();
    final bDate = birthDateController.text.trim();

    if (fName.isEmpty || lName.isEmpty || addr.isEmpty || bDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (selectedCustomer == null) {
      // Add new customer
      final newCustomer = Customer(
        null, // null because ID will be auto-generated
        fName,
        lName,
        addr,
        bDate,
      );
      final id = await dao.insertCustomer(newCustomer);
      final inserted = Customer(id, fName, lName, addr, bDate); // assign id after insert
      setState(() {
        customers.add(inserted);
      });
    } else {
      // Update existing customer
      selectedCustomer!
        ..firstName = fName
        ..lastName = lName
        ..address = addr
        ..birthDate = bDate;

      await dao.updateCustomer(selectedCustomer!);
      setState(() {
        // Refresh UI if needed
      });
    }

    setState(() {
      selectedCustomer = null;
      firstNameController.clear();
      lastNameController.clear();
      addressController.clear();
      birthDateController.clear();
    });
  }


  void _confirmDelete(Customer customer) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.firstName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('No')),
          TextButton(
            onPressed: () async {
              await dao.deleteCustomer(customer);
              customers.remove(customer);
              if (selectedCustomer == customer) selectedCustomer = null;
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (_, index) {
        final customer = customers[index];
        return ListTile(
          title: Text('${customer.firstName} ${customer.lastName}'),
          subtitle: Text('DOB: ${customer.birthDate}'),
          onTap: () {
            setState(() {
              selectedCustomer = customer;
              _loadDataIntoFields();
            });
          },
          onLongPress: () => _confirmDelete(customer),
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
        TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
        TextField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
        TextField(controller: birthDateController, decoration: InputDecoration(labelText: 'Birth Date')),
        Row(
          children: [
            ElevatedButton(onPressed: saveCustomer, child: Text(selectedCustomer == null ? 'Add' : 'Update')),
            SizedBox(width: 16),
            if (selectedCustomer != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCustomer = null;
                    firstNameController.clear();
                    lastNameController.clear();
                    addressController.clear();
                    birthDateController.clear();
                  });
                },
                child: Text('Cancel'),
              )
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveLayout() {
    var size = MediaQuery.of(context).size;
    if (size.width > 720) {
      return Row(
        children: [
          Expanded(child: _buildListView()),
          VerticalDivider(),
          Expanded(child: SingleChildScrollView(child: _buildForm())),
        ],
      );
    } else {
      return selectedCustomer == null
          ? _buildListView()
          : SingleChildScrollView(child: _buildForm());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer List"),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Instructions'),
                  content: Text('Tap a customer to update, long press to delete.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _buildResponsiveLayout(),
      ),
    );
  }
}
