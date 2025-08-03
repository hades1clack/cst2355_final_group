import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'database/app_database.dart';
import 'database/customer.dart';
import 'database/customer_dao.dart';
import 'customer_form.dart';

class CustomerPage extends StatefulWidget {
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const CustomerPage({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late AppDatabase database;
  late CustomerDao dao;
  List<Customer> customers = [];
  Customer? selectedCustomer;
  // var _isDaoReady;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // Future<void> _initDatabase() async {
  //   database = await $FloorAppDatabase.databaseBuilder('customer.db').build();
  //   dao = database.customerDao;
  //   await _refreshCustomers();
  // }
  Future<void> _initDatabase() async {
    database = await $FloorAppDatabase.databaseBuilder('customer.db').build();
    dao = database.customerDao;
    customers = await dao.findAll();
    setState(() {
      // _isDaoReady = true; // or _isLoading = false
    });
  }

  Future<void> _refreshCustomers() async {
    customers = await dao.findAll();
    setState(() {});
  }

  void _clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    addressController.clear();
    birthDateController.clear();
  }

  void _populateForm(Customer customer) {
    firstNameController.text = customer.firstName;
    lastNameController.text = customer.lastName;
    addressController.text = customer.address;
    birthDateController.text = customer.birthDate;
  }

  Future<void> _updateCustomer() async {
    if (selectedCustomer == null) return;

    selectedCustomer!
      ..firstName = firstNameController.text.trim()
      ..lastName = lastNameController.text.trim()
      ..address = addressController.text.trim()
      ..birthDate = birthDateController.text.trim();

    await dao.updateCustomer(selectedCustomer!);
    await _refreshCustomers();
    setState(() {
      selectedCustomer=null;// Go back to list after update
    });
  }

  Future<void> _confirmDelete(Customer customer) async {
    final t = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.translate('confirm_delete') ?? 'Confirm Delete'),
        content: Text('${t.translate('delete_customer')} ${customer.firstName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.translate('cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await dao.deleteCustomer(customer);

      setState(() {
        selectedCustomer = null;
        _clearForm();
      });

      await _refreshCustomers();

    }
  }

  Widget _buildCustomerList(AppLocalizations t) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t.translate('customer_list') ?? 'Customer List',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () async {
                final Customer? newCustomer = await Navigator.push<Customer>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerFormPage(
                      locale: widget.locale,
                      onLanguageChanged: widget.onLanguageChanged,
                    ),
                  ),
                );

                if (newCustomer != null) {
                  try {
                    await dao.insertCustomer(newCustomer);
                    await _refreshCustomers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.translate('customer_added_successfully') ?? 'Customer added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.translate('add_failed') ?? 'Failed to add customer: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: Text(t.translate('add') ?? 'Add'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: customers.isEmpty
              ? Center(child: Text(t.translate('no_customers') ?? 'No customers available'))
              : ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final c = customers[index];
              return ListTile(
                title: Text('${c.firstName} ${c.lastName}'),
                subtitle: Text(c.address),
                onTap: () {
                  setState(() {
                    selectedCustomer = c;
                    _populateForm(c);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(AppLocalizations t) {
    if (selectedCustomer == null) {
      return const Center(child: Text(''));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: InputDecoration(labelText: t.translate('first_name') ?? 'First Name'),
          ),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(labelText: t.translate('last_name') ?? 'Last Name'),
          ),
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(labelText: t.translate('address') ?? 'Address'),
          ),
          TextFormField(
            controller: birthDateController,
            decoration: InputDecoration(labelText: t.translate('birth_date') ?? 'Birth Date'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _updateCustomer,
                child: Text(t.translate('update') ?? 'Update'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedCustomer != null) {
                    _confirmDelete(selectedCustomer!);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(t.translate('delete') ?? 'Delete'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCustomer = null; // Manual close button
                  });
                },
                child: Text(t.translate('close') ?? 'Close'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _responsiveLayout(AppLocalizations t) {
    final size = MediaQuery.of(context).size;
    if (size.width > size.height && size.width > 720) {
      return Row(
        children: [
          Expanded(flex: 2, child: _buildCustomerList(t)),
          Expanded(flex: 2, child: _buildDetails(t)),
        ],
      );
    } else {
      return selectedCustomer == null
          ? _buildCustomerList(t)
          : _buildDetails(t);
    }
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: widget.locale,
        icon: const Icon(Icons.language, color: Colors.white),
        dropdownColor: Colors.blue,
        onChanged: (Locale? locale) {
          if (locale != null) widget.onLanguageChanged(locale);
        },
        items: const [
          DropdownMenuItem(value: Locale('en'), child: Text('English')),
          DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('customer_list') ?? 'Customer List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildLanguageDropdown(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/customer_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Container(
          //   color: Colors.black.withOpacity(0.4), // Optional overlay for readability
          // ),
          _responsiveLayout(t),
        ],
      ),

    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
