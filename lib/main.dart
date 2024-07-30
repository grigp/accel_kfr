import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:process_control/process_control_app.dart';
import 'package:process_control/repositories/database/abstract_database_repository.dart';
import 'package:process_control/repositories/database/database.dart';
import 'package:process_control/repositories/source/abstract_source_repository.dart';
import 'package:process_control/repositories/source/accel_driver.dart';
import 'package:process_control/repositories/source/sinus_generator.dart';

void main() {
  GetIt.I.registerLazySingleton<AbstractSourceRepository>(
          () => AccelDriver()//SinusGenerator()
  );

  GetIt.I.registerLazySingleton<AbstractDatabaseRepository>(
          () => Database()
  );

  runApp(const ProcessControlApp());
}
