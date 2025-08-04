// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $ReservationDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $ReservationDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $ReservationDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<ReservationDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorReservationDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ReservationDatabaseBuilderContract databaseBuilder(String name) =>
      _$ReservationDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $ReservationDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$ReservationDatabaseBuilder(null);
}

class _$ReservationDatabaseBuilder
    implements $ReservationDatabaseBuilderContract {
  _$ReservationDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $ReservationDatabaseBuilderContract addMigrations(
      List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $ReservationDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<ReservationDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$ReservationDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ReservationDatabase extends ReservationDatabase {
  _$ReservationDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ReservationDao? _reservationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `reservations` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` TEXT NOT NULL, `flightId` TEXT NOT NULL, `flightDate` TEXT NOT NULL, `reservationName` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ReservationDao get reservationDao {
    return _reservationDaoInstance ??=
        _$ReservationDao(database, changeListener);
  }
}

class _$ReservationDao extends ReservationDao {
  _$ReservationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reservationInsertionAdapter = InsertionAdapter(
            database,
            'reservations',
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                }),
        _reservationUpdateAdapter = UpdateAdapter(
            database,
            'reservations',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                }),
        _reservationDeletionAdapter = DeletionAdapter(
            database,
            'reservations',
            ['id'],
            (Reservation item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'flightId': item.flightId,
                  'flightDate': item.flightDate,
                  'reservationName': item.reservationName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Reservation> _reservationInsertionAdapter;

  final UpdateAdapter<Reservation> _reservationUpdateAdapter;

  final DeletionAdapter<Reservation> _reservationDeletionAdapter;

  @override
  Future<List<Reservation>> findAllReservations() async {
    return _queryAdapter.queryList('SELECT * FROM reservations',
        mapper: (Map<String, Object?> row) => Reservation(
            id: row['id'] as int?,
            customerId: row['customerId'] as String,
            flightId: row['flightId'] as String,
            flightDate: row['flightDate'] as String,
            reservationName: row['reservationName'] as String));
  }

  @override
  Future<void> insertReservation(Reservation reservation) async {
    await _reservationInsertionAdapter.insert(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReservation(Reservation reservation) async {
    await _reservationUpdateAdapter.update(
        reservation, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReservation(Reservation reservation) async {
    await _reservationDeletionAdapter.delete(reservation);
  }
}
