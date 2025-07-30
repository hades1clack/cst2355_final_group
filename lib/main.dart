import 'package:flutter/material.dart';
import 'package:cst2355_final_group/database/app_database.dart';
import 'package:cst2355_final_group/database/airplane.dart';
import 'package:cst2355_final_group/pages/airplane_detail_page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}
class MyApp extends StatelessWidget {
  final AppDatabase database;

  MyApp(this.database, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airplane List Page Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: AirplaneListPage(database: database),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _AirplaneListPageState();
// }

class AirplaneListPage extends StatefulWidget {
  final AppDatabase database;

  const AirplaneListPage({Key? key, required this.database}) : super(key: key);

  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  List<Airplane> airplanes = [];

  @override
  void initState() {
    super.initState();
    _loadAirplanes();
  }

  Future<void> _loadAirplanes() async {
    final list = await widget.database.airplaneDao.getAllAirplanes();
    setState(() {
      airplanes = list;
    });
  }

  void _navigateToAdd() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AirplaneDetailPage(database: widget.database)),
    );
    if (result == true) {
      _loadAirplanes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane added!')),
      );
    }
  }

  void _navigateToEdit(Airplane airplane) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AirplaneDetailPage(database: widget.database, airplane: airplane)),
    );
    if (result == true) {
      _loadAirplanes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Airplane updated/deleted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airplane List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Instructions'),
                  content: const Text(
                      'Use the + button to add airplanes.\nTap an airplane to edit or delete it.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: airplanes.isEmpty
          ? const Center(child: Text('No airplanes yet. Tap + to add one.'))
          : ListView.builder(
        itemCount: airplanes.length,
        itemBuilder: (context, index) {
          final airplane = airplanes[index];
          return ListTile(
            title: Text(airplane.type),
            subtitle: Text(
                'Passengers: ${airplane.passengerCount}, Speed: ${airplane.maxSpeed} km/h, Range: ${airplane.range} km'),
            onTap: () => _navigateToEdit(airplane),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
//
// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
//   runApp(MyApp(database));
// }
// class MyApp extends StatelessWidget {
//   final AppDatabase database;
//
//   MyApp(this.database, {Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Airplane List Page Demo',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
//       ),
//       home: const MyHomePage(title: 'Airplane List Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   late final AppDatabase db;
//
//   @override
//   void initState() {
//     super.initState();
//     initDatabase(); // 初始化数据库
//   }
//
//   Future<void> initDatabase() async {
//     db = await $FloorAppDatabase
//         .databaseBuilder('app_database.db')
//         .build();
//   }
//
//   Future<void> _addTestAirplane() async {
//     final airplane = Airplane(
//       id: 1,
//       type: 'Airbus A380',
//       passengerCount: 853,
//       maxSpeed: 1020,
//       range:15700,
//
//     );
//     await db.airplaneDao.insertAirplane(airplane);
//
//     final allPlanes = await db.airplaneDao.getAllAirplanes();
//     print('There are total ${allPlanes.length} airplane');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//
//         title: Text(widget.title),
//       ),
//       body: Center(
//
//         child: Column(
//
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('home page'),
//             Text(
//               '',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
