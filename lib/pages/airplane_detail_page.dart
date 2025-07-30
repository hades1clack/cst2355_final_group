import 'package:flutter/material.dart';
import 'package:cst2355_final_group/database/app_database.dart';
import 'package:cst2355_final_group/database/airplane.dart';


class AirplaneDetailPage extends StatefulWidget {
  final AppDatabase database;
  final Airplane? airplane; // null 表示新增，非空表示编辑

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
    _passengersController = TextEditingController(text: widget.airplane?.passengerCount.toString() ?? '');
    _maxSpeedController = TextEditingController(text: widget.airplane?.maxSpeed.toString() ?? '');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane updated')),
      );
    } else {
      await widget.database.airplaneDao.insertAirplane(airplane);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane added')),
      );
    }

    Navigator.pop(context, true); // 通知列表刷新
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane deleted')),
      );
      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.lightBlue.shade700),
              border: InputBorder.none,
            ),
            keyboardType: keyboardType,
            validator: validator,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Airplane' : 'Add Airplane'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade200, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _typeController,
                    label: 'Airplane Type',
                    icon: Icons.flight_takeoff,
                    validator: (value) =>
                    (value == null || value.isEmpty) ? 'Please enter airplane type' : null,
                  ),
                  _buildTextField(
                    controller: _passengersController,
                    label: 'Passenger Count',
                    icon: Icons.event_seat,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter passenger count';
                      if (int.tryParse(value) == null) return 'Must be a valid number';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _maxSpeedController,
                    label: 'Max Speed (km/h)',
                    icon: Icons.speed,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter max speed';
                      if (double.tryParse(value) == null) return 'Must be a valid number';
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _rangeController,
                    label: 'Range (km)',
                    icon: Icons.route,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter range';
                      if (double.tryParse(value) == null) return 'Must be a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveAirplane,
                    icon: const Icon(Icons.add_circle),
                    label: Text(isEditMode ? 'Update Airplane' : 'Add Airplane'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlue.shade700,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isEditMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton.icon(
                        onPressed: _deleteAirplane,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Airplane'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red.shade700,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// class AirplaneDetailPage extends StatefulWidget {
//   final AppDatabase database;
//   final Airplane? airplane; // null means add mode, non-null means edit mode
//
//   const AirplaneDetailPage({Key? key, required this.database, this.airplane}) : super(key: key);
//
//   @override
//   _AirplaneDetailPageState createState() => _AirplaneDetailPageState();
// }
//
// class _AirplaneDetailPageState extends State<AirplaneDetailPage> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _typeController;
//   late TextEditingController _passengersController;
//   late TextEditingController _maxSpeedController;
//   late TextEditingController _rangeController;
//
//   bool get isEditMode => widget.airplane != null;
//
//   @override
//   void initState() {
//     super.initState();
//     _typeController = TextEditingController(text: widget.airplane?.type ?? '');
//     _passengersController =
//         TextEditingController(text: widget.airplane?.passengerCount.toString() ?? '');
//     _maxSpeedController =
//         TextEditingController(text: widget.airplane?.maxSpeed.toString() ?? '');
//     _rangeController = TextEditingController(text: widget.airplane?.range.toString() ?? '');
//   }
//
//   @override
//   void dispose() {
//     _typeController.dispose();
//     _passengersController.dispose();
//     _maxSpeedController.dispose();
//     _rangeController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveAirplane() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final type = _typeController.text.trim();
//     final passengers = int.parse(_passengersController.text.trim());
//     final maxSpeed = double.parse(_maxSpeedController.text.trim());
//     final range = double.parse(_rangeController.text.trim());
//
//     final airplane = Airplane(
//       id: widget.airplane?.id,
//       type: type,
//       passengerCount: passengers,
//       maxSpeed: maxSpeed,
//       range: range,
//     );
//
//     if (isEditMode) {
//       await widget.database.airplaneDao.updateAirplane(airplane);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane updated')));
//     } else {
//       await widget.database.airplaneDao.insertAirplane(airplane);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane added')));
//     }
//
//     Navigator.pop(context, true); // 返回true通知列表刷新
//   }
//
//   Future<void> _deleteAirplane() async {
//     if (!isEditMode) return;
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: Text('Delete airplane "${widget.airplane!.type}"?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       await widget.database.airplaneDao.deleteAirplane(widget.airplane!);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Airplane deleted')));
//       Navigator.pop(context, true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditMode ? 'Edit Airplane' : 'Add Airplane'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _typeController,
//                 decoration: const InputDecoration(labelText: 'Airplane Type'),
//                 validator: (value) => value == null || value.isEmpty ? 'Required' : null,
//               ),
//               TextFormField(
//                 controller: _passengersController,
//                 decoration: const InputDecoration(labelText: 'Passengers'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (int.tryParse(value) == null) return 'Must be a number';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _maxSpeedController,
//                 decoration: const InputDecoration(labelText: 'Max Speed (km/h)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (int.tryParse(value) == null) return 'Must be a number';
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _rangeController,
//                 decoration: const InputDecoration(labelText: 'Range (km)'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) return 'Required';
//                   if (int.tryParse(value) == null) return 'Must be a number';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _saveAirplane,
//                 child: Text(isEditMode ? 'Update' : 'Add'),
//               ),
//               if (isEditMode)
//                 ElevatedButton(
//                   onPressed: _deleteAirplane,
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                   child: const Text('Delete'),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }