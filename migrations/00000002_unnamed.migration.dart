import 'dart:async';
import 'package:aqueduct/aqueduct.dart';

class Migration2 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable("_Hero", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("name", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: true,
          isUnique: false)
    ]));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {
    final _heroes = [
      'Mr. Nice',
      'Narco',
      'Bombasto',
      'Celeritas',
      'Magneta',
    ];

    for (var hero in _heroes) {
      await database.store.execute('INSERT INTO _hero(name) VALUES(@name)',
          substitutionValues: {"name": hero});
    }
  }
}
