import 'package:flutter/material.dart';
import 'package:cst2355_final_group/repository.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherPage extends StatefulWidget {
  @override
  State<OtherPage> createState() => OtherPageState();
}

class OtherPageState extends State<OtherPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
    });

    firstNameController.addListener(() {
      DataRepository.firstName = firstNameController.text;
      DataRepository.saveData();
    });
    lastNameController.addListener(() {
      DataRepository.lastName = lastNameController.text;
      DataRepository.saveData();
    });
    phoneController.addListener(() {
      DataRepository.phoneNumber = phoneController.text;
      DataRepository.saveData();
    });
    emailController.addListener(() {
      DataRepository.email = emailController.text;
      DataRepository.saveData();
    });
    loadDataIntoFileds();
  }

  loadDataIntoFileds() async {
    await DataRepository.loadData();
    setState(() {
      firstNameController.text = DataRepository.firstName;
      lastNameController.text = DataRepository.lastName;
      phoneController.text = DataRepository.phoneNumber;
      emailController.text = DataRepository.email;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showNotSupportedDialog(url);
    }
  }

  void _showNotSupportedDialog(String url) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text('URL not supported'),
        content: Text('Cannot launch this URL:\n$url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Welcome Back ${DataRepository.loginName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: "FirstName"),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: "LastName"),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: "Phone"),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.phone),
                    onPressed: () {
                      final phone = phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        _launchUrl('tel:$phone');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.sms),
                    onPressed: () {
                      final phone = phoneController.text.trim();
                      if (phone.isNotEmpty) {
                        _launchUrl('sms:$phone');
                      }
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.email),
                    onPressed: () {
                      final email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        _launchUrl('mailto:$email');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ); //Use a Scaffold to layout a page with an AppBar and main body region
  }
}
