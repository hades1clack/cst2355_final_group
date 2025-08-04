import 'package:flutter/material.dart';
import 'AppLocalizations.dart';
import 'database/customer.dart';
import 'repository.dart';

/// A form page that allows the user to enter or edit customer information.
/// Includes localization and support for loading previously saved data.
class CustomerFormPage extends StatefulWidget {
  /// The current locale for localization.
  final Locale locale;

  /// Callback function that triggers when the user changes the language.
  final Function(Locale) onLanguageChanged;

  /// Creates a [CustomerFormPage].
  const CustomerFormPage({
    super.key,
    required this.locale,
    required this.onLanguageChanged,
  });
  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

/// The state class for [CustomerFormPage].
class _CustomerFormPageState extends State<CustomerFormPage> {
  /// Key used to identify and validate the form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the first name input field.
  final TextEditingController firstNameController = TextEditingController();

  /// Controller for the last name input field.
  final TextEditingController lastNameController = TextEditingController();

  /// Controller for the address input field.
  final TextEditingController addressController = TextEditingController();

  /// Controller for the birth date input field.
  final TextEditingController birthDateController = TextEditingController();

  /// Tracks the selected language from the dropdown.
  late Locale _currentDropdownLocale;
  @override
  void initState() {
    super.initState();
    _currentDropdownLocale = _normalizeLocale(widget.locale);
    // Prompt the user to load saved form data after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldLoad = await showDialog<bool>(
        context: context,
        builder: (context) {
          final t = AppLocalizations.of(context)!;

          return AlertDialog(
            title: Text(
              t.translate('load_data_title') ?? 'Load previous data?',
            ),
            content: Text(
              t.translate('load_data_prompt') ??
                  'Do you want to load the last saved customer data?',
            ),
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

    // Add listeners to auto-save input changes
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

  /// Normalizes the locale to 'en' or 'fr' only.
  Locale _normalizeLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return const Locale('fr');
      case 'en':
      default:
        return const Locale('en');
    }
  }

  /// Validates and saves the form, then returns a [Customer] object back to the previous screen.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final fName = firstNameController.text.trim();
    final lName = lastNameController.text.trim();
    final addr = addressController.text.trim();
    final bDate = birthDateController.text.trim();

    final newCustomer = Customer(null, fName, lName, addr, bDate);

    Navigator.pop(context, newCustomer); // send customer back
  }

  /// Loads previously saved form data from the [DataRepository] into the input fields.
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
          /// Language selection dropdown in the AppBar.
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
                    widget.onLanguageChanged(
                      locale,
                    ); // notify parent to change language
                  }
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(
                    value: Locale('fr'),
                    child: Text('Français'),
                  ),
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
                  /// Input field for first name.
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

                  /// Input field for last name.
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

                  /// Input field for address.
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

                  /// Input field for birth date.
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

                  /// Submit button to save the form.
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
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

  /// Disposes all text controllers when the widget is removed from the widget tree.
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
}
