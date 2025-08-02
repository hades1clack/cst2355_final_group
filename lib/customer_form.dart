import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'database/customer.dart';
import 'database/customer_dao.dart';

class CustomerFormPage extends StatefulWidget {
  final CustomerDao dao;
  final Customer? customer;
  final VoidCallback onSaved;
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const CustomerFormPage({
    super.key,
    required this.dao,
    this.customer,
    required this.onSaved,
    required this.locale,
    required this.onLanguageChanged,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      firstNameController.text = widget.customer!.firstName;
      lastNameController.text = widget.customer!.lastName;
      addressController.text = widget.customer!.address;
      birthDateController.text = widget.customer!.birthDate;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final fName = firstNameController.text.trim();
    final lName = lastNameController.text.trim();
    final addr = addressController.text.trim();
    final bDate = birthDateController.text.trim();

    if (widget.customer == null) {
      // New
      final newCustomer = Customer(null, fName, lName, addr, bDate);
      await widget.dao.insertCustomer(newCustomer);
    } else {
      // Update
      final updated = widget.customer!
        ..firstName = fName
        ..lastName = lName
        ..address = addr
        ..birthDate = bDate;
      await widget.dao.updateCustomer(updated);
    }

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? t.translate('edit_customer') ?? 'Edit Customer'
            : t.translate('add_customer') ?? 'Add Customer'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: widget.locale,
              icon: Icon(Icons.language, color: Colors.white),
              dropdownColor: Colors.blue,
              onChanged: (Locale? locale) {
                if (locale != null) {
                  widget.onLanguageChanged(locale);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: t.translate('first_name') ?? 'First Name'),
                validator: (value) => value == null || value.isEmpty
                    ? t.translate('field_required') ?? 'Required'
                    : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: t.translate('last_name') ?? 'Last Name'),
                validator: (value) => value == null || value.isEmpty
                    ? t.translate('field_required') ?? 'Required'
                    : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: t.translate('address') ?? 'Address'),
                validator: (value) => value == null || value.isEmpty
                    ? t.translate('field_required') ?? 'Required'
                    : null,
              ),
              TextFormField(
                controller: birthDateController,
                decoration: InputDecoration(labelText: t.translate('birth_date') ?? 'Birth Date'),
                validator: (value) => value == null || value.isEmpty
                    ? t.translate('field_required') ?? 'Required'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(t.translate(isEditing ? 'update' : 'add') ?? (isEditing ? 'Update' : 'Add')),
              )
            ],
          ),
        ),
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
