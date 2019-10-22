import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String currencyTable = "CurrencyTable";

final String nameColumn = "name";
final String valueColumn = "value";

class CurrencyHelper {
  static final CurrencyHelper _instance = CurrencyHelper.internal();

  factory CurrencyHelper() => _instance;

  CurrencyHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "currencies.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $currencyTable($nameColumn TEXT, $valueColumn REAL)"
      );
    });
  }

  Future<Currency> saveCurrency(Currency currency) async {
    Database dbCurrency = await db;
    await dbCurrency.insert(currencyTable, currency.toMap());

    return currency;
  }

  Future<Currency> getCurrency(String name) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(currencyTable,
        where: "$nameColumn = ?",
        whereArgs: [name]);
    if(maps.length > 0){
      return Currency.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future deleteCurrencies() async {
    Database dbContact = await db;
    return await dbContact.rawDelete("DELETE FROM $currencyTable");
  }

  Future<List> getAllCurrencies() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $currencyTable");
    List<Currency> listContact = List();
    for(Map m in listMap){
      listContact.add(Currency.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $currencyTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Currency{
  String name;
  double value;

  Currency(String name, double value){
    this.name = name;
    this.value = value;
  }

  Currency.fromMap(Map map){
    name = map[nameColumn];
    value = map[valueColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      valueColumn: value
    };
    return map;
  }
}