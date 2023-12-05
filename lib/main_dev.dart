import 'flavors.dart';
import 'main_prod.dart' as runner;

Future<void> main() async {
  F.appFlavor = Flavor.dev;
  await runner.main();
}
