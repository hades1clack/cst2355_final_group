import 'package:flutter/material.dart';
import 'package:cst2355_final_group/database/app_database.dart';
import 'package:cst2355_final_group/database/airplane.dart';

class AirplaneDetailPage extends StatefulWidget {
  final AppDatabase database;
  final Airplane? airplane; // null means add mode, non-null means edit mode

  const AirplaneDetailPage({Key? key, required this.database, this.airplane}) : super(key: key);

  @override
  _AirplaneDetailPageState createState() => _AirplaneDetailPageState();
}

class _AirplaneDetailPageState extends State<AirplaneDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeController;
  late TextEditingController _passengersController;
  late TextEditingController _maxSpeedController;
  late TextEditingController _rangeController;

  bool get isEditMode => widget.airplane != null;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.airplane?.type ?? '');
    _passengersController =
        TextEditingController(text: widget.airplane?.passengerCount.toString() ?? '');
    _maxSpeedController =
        TextEditingController(text: widget.airplane?.maxSpeed.toString() ?? '');
    _rangeController = TextEditingController(text: widget.airplane?.range.toString() ?? '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _passengersController.dispose();
    _maxSpeedController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  Future<void> _saveAirplane() async {
    if (!_formKey.currentState!.validate()) return;

    final type = _typeController.text.trim();
    final passengers = int.parse(_passengersController.text.trim());
    final maxSpeed = double.parse(_maxSpeedController.text.trim());
    final range = double.parse(_rangeController.text.trim());

    final airplane = Airplane(
      id: widget.airplane?.id,
      type: type,
      passengerCount: passengers,
      maxSpeed: maxSpeed,
      range: range,
    );

    if (isEditMode) {
      await widget.database.airplaneDao.updateAirplane(airplane);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane updated')));
    } else {
      await widget.database.airplaneDao.insertAirplane(airplane);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane added')));
    }

    Navigator.pop(context, true); // 返回true通知列表刷新
  }

  Future<void> _deleteAirplane() async {
    if (!isEditMode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete airplane "${widget.airplane!.type}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.database.airplaneDao.deleteAirplane(widget.airplane!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane deleted')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Airplane' : 'Add Airplane'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Airplane Type'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _passengersController,
                decoration: const InputDecoration(labelText: 'Passengers'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              TextFormField(
                controller: _maxSpeedController,
                decoration: const InputDecoration(labelText: 'Max Speed (km/h)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              TextFormField(
                controller: _rangeController,
                decoration: const InputDecoration(labelText: 'Range (km)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAirplane,
                child: Text(isEditMode ? 'Update' : 'Add'),
              ),
              if (isEditMode)
                ElevatedButton(
                  onPressed: _deleteAirplane,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}