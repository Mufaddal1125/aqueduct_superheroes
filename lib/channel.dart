import 'package:super_heroes/super_heroes.dart';
import 'model/hero.dart';
/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class SuperHeroesChannel extends ApplicationChannel {
  ManagedContext context;
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo('postgres', 'password', 'localhost', 5555, 'superheroes');

    context = ManagedContext(dataModel, persistentStore);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
      .route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      });

    router
      .route("/heroes/[:id]")
      .link(() => HeroesController(context));

    return router;
  }
}

class HeroesController extends ResourceController{
  HeroesController(this.context);
  ManagedContext context;

  @Operation.get()
  Future<Response> getHeroByName({@Bind.query('name') String name}) async {
    final heroQuery = Query<Hero>(context);
    if(name != null){
      heroQuery.where((x) => x.name).contains(name, caseSensitive: false);
    }
    final _heroes = await heroQuery.fetch();
    return Response.ok(_heroes);
  }

  @Operation.get('id')
  Future<Response> getHeroById(@Bind.path('id') int id) async {
    final heroQuery = Query<Hero>(context)..where((x) => x.id).equalTo(id);
    final hero = await heroQuery.fetchOne();
    if(hero == null) {
      return Response.notFound();
    }

    return Response.ok(hero);
  }

  @Operation.post()
  Future<Response> createHero() async{
    final hero = Hero()..read(await request.body.decode(), ignore: ['id']);

    final query = Query<Hero>(context)..values.name = hero.name;
    final insertedHero = await query.insert();
    if(insertedHero == null ){
      Response.serverError();
    }
    return Response.ok(insertedHero);
  }

  @Operation.delete('id')
  Future<Response> deleteHero({@Bind.path('id') int id}) async {
    print('[deleteHero]');
    final heroQuery = Query<Hero>(context)..where((x) => x.id).equalTo(id);
    if(heroQuery != null){
      final deletedHero = await heroQuery.delete();
      Response.ok({"message": "Deleted Hero"});
    }
    Response.notFound();
  }

}