import 'dart:async';
import 'package:floor/floor.dart';
import 'airplane_dao.dart';
import 'airplane.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [Airplane])
abstract class AppDatabase extends FloorDatabase {
  AirplaneDao get airplaneDao;
}