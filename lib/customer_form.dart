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
  late Locale _currentDropdownLocale;
  @override
  void initState() {
    super.initState();
    _currentDropdownLocale = _normalizeLocale(widget.locale);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldLoad = await showDialog<bool>(
        context: context,
        builder:
            (context) {
          final t = AppLocalizations.of(context)!;

          return AlertDialog(
            title: Text(t.translate('load_data_title') ?? 'Load previous data?'),
            content: Text(t.translate('load_data_prompt') ?? 'Do you want to load the last saved customer data?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(t.translate('no') ?? 'No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(t.translate('yes') ?? 'Yes'),
              ),
            ],
          );
        },
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

  @override
  void didUpdateWidget(CustomerFormPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      setState(() {
        _currentDropdownLocale = _normalizeLocale(widget.locale);
      });
    }
  }

  Locale _normalizeLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return const Locale('fr');
      case 'en':
      default:
        return const Locale('en');
    }
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
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.blue, // Dropdown menu background
                highlightColor: Colors.blue[800], // Selected item highlight
                splashColor: Colors.blue[700], // Ripple effect
                textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white, // Text color
                  displayColor: Colors.white,
                ),
              ),
              child: DropdownButton<Locale>(
                value: _currentDropdownLocale,
                icon: const Icon(Icons.language, color: Colors.white),
                dropdownColor: Colors.blue,
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    setState(() {
                      _currentDropdownLocale = locale; // update local selection
                    });
                    widget.onLanguageChanged(locale); // notify parent to change language
                  }
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/customer_bg.jpg', fit: BoxFit.cover),
          ),
          // Container(
          //   color: Colors.black.withOpacity(0.4), // Optional dark overlay
          // ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: t.translate('First_Name') ?? 'First Name',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? t.translate('field_required') ?? 'Required'
                                : null,
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: t.translate('Last_Name') ?? 'Last Name',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? t.translate('field_required') ?? 'Required'
                                : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: t.translate('Address') ?? 'Address',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? t.translate('field_required') ?? 'Required'
                                : null,
                  ),
                  TextFormField(
                    controller: birthDateController,
                    decoration: InputDecoration(
                      labelText: t.translate('Birth_Date') ?? 'Birth Date',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? t.translate('field_required') ?? 'Required'
                                : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text(t.translate('Submit') ?? 'Submit'),
                  ),
                ],
              ),
            ),
          ),
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
