import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sight/models/record.dart';
import 'package:sqflite/sqflite.dart';

class ObjectsDb {
  ObjectsDb();

  void addToDb(Record record) async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'records_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE records(object TEXT, time TEXT, date TEXT, error TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    Future<void> insertRecord(Record record) async {
      // Get a reference to the database.
      final Database db = await database;

      // Insert the Record into the correct table. Also specify the
      // `conflictAlgorithm`. In this case, if the same dog is inserted
      // multiple times, it replaces the previous data.
      await db.insert(
        'records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    Future<List<Record>> records() async {
      // Get a reference to the database.
      final Database db = await database;

      // Query the table for all The Records.
      final List<Map<String, dynamic>> maps = await db.query('records');

      // Convert the List<Map<String, dynamic> into a List<Record>.
      return List.generate(maps.length, (i) {
        return Record(
          object: maps[i]['object'],
          time: maps[i]['time'],
          date: maps[i]['date'],
          error: maps[i]['error'],
        );
      });
    }

    await insertRecord(record);

    // Print the list of dogs (only Fido for now).
    print(await records());

    // Update Fido's age and save it to the database.
//    fido = Record(
//      id: fido.id,
//      name: fido.name,
//      age: fido.age + 7,
//    );
//    await updateDog(fido);
  }
}
