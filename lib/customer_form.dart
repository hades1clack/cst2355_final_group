import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'database/customer.dart';
import 'repository.dart';

class CustomerFormPage extends StatefulWidget {
  final Locale locale;
  final Function(Locale) onLanguageChanged;

  const CustomerFormPage({
    super.key,
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldLoad = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Load previous data?'),
          content: const Text('Do you want to load the last saved customer data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldLoad == true) {
        _loadDataIntoFields();
      }
    });

    // Save form changes
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final fName = firstNameController.text.trim();
    final lName = lastNameController.text.trim();
    final addr = addressController.text.trim();
    final bDate = birthDateController.text.trim();

    final newCustomer = Customer(null, fName, lName, addr, bDate);

    Navigator.pop(context, newCustomer); // send customer back
  }
  void _loadDataIntoFields() async {
    await DataRepository.loadData();
    setState(() {
      firstNameController.text = DataRepository.firstName;
      lastNameController.text = DataRepository.lastName;
      addressController.text = DataRepository.address;
      birthDateController.text = DataRepository.birthDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('add_customer') ?? 'Add Customer'),
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
                child: Text(t.translate('add') ?? 'Add'),
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
