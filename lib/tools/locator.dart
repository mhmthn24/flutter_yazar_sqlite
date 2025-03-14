import 'package:flutter_yazar_sqlite/repository/database_repository.dart';
import 'package:flutter_yazar_sqlite/service/sqflite/sqflite_database_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

setupLocator(){
  locator.registerLazySingleton(() => DatabaseRepository());
  locator.registerLazySingleton(() =>  SqfliteDatabaseService());
}