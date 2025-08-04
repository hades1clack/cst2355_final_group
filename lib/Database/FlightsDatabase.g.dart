// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FlightsDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $FlightsDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $FlightsDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $FlightsDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<FlightsDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorFlightsDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $FlightsDatabaseBuilderContract databaseBuilder(String name) =>
      _$FlightsDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $FlightsDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$FlightsDatabaseBuilder(null);
}

class _$FlightsDatabaseBuilder implements $FlightsDatabaseBuilderContract {
  _$FlightsDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $FlightsDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $FlightsDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<FlightsDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlightsDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlightsDatabase extends FlightsDatabase {
  _$FlightsDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  FlightDAO? _getDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Flights` (`id` INTEGER, `flightNumber` TEXT NOT NULL, `departureCity` TEXT NOT NULL, `destinationCity` TEXT NOT NULL, `departureTime` TEXT NOT NULL, `arrivalTime` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  FlightDAO get getDao {
    return _getDaoInstance ??= _$FlightDAO(database, changeListener);
  }
}

class _$FlightDAO extends FlightDAO {
  _$FlightDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _flightsInsertionAdapter = InsertionAdapter(
            database,
            'Flights',
            (Flights item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                }),
        _flightsUpdateAdapter = UpdateAdapter(
            database,
            'Flights',
            ['id'],
            (Flights item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                }),
        _flightsDeletionAdapter = DeletionAdapter(
            database,
            'Flights',
            ['id'],
            (Flights item) => <String, Object?>{
                  'id': item.id,
                  'flightNumber': item.flightNumber,
                  'departureCity': item.departureCity,
                  'destinationCity': item.destinationCity,
                  'departureTime': item.departureTime,
                  'arrivalTime': item.arrivalTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Flights> _flightsInsertionAdapter;

  final UpdateAdapter<Flights> _flightsUpdateAdapter;

  final DeletionAdapter<Flights> _flightsDeletionAdapter;

  @override
  Future<List<Flights>> getAllFlight() async {
    return _queryAdapter.queryList('SELECT * FROM Flights',
        mapper: (Map<String, Object?> row) => Flights(
            id: row['id'] as int?,
            flightNumber: row['flightNumber'] as String,
            departureCity: row['departureCity'] as String,
            destinationCity: row['destinationCity'] as String,
            departureTime: row['departureTime'] as String,
            arrivalTime: row['arrivalTime'] as String));
  }

  @override
  Future<void> addFlights(Flights toBeInserted) async {
    await _flightsInsertionAdapter.insert(
        toBeInserted, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFlights(Flights newFlight) async {
    await _flightsUpdateAdapter.update(newFlight, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFlights(Flights toBeDeleted) async {
    await _flightsDeletionAdapter.delete(toBeDeleted);
  }
}
