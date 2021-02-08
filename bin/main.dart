import 'package:super_heroes/super_heroes.dart';

Future main() async {
  final app = Application<SuperHeroesChannel>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 8888;

  await app.startOnCurrentIsolate();

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}