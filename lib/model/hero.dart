import 'package:super_heroes/super_heroes.dart';

class Hero extends ManagedObject<_Hero> implements _Hero{}

class _Hero{
  @primaryKey
  int id;

  @Column(unique: false, nullable: true)
  String name;
}