import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart' as di;
import 'package:flutter_ecommerce/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.configureDependencies();
  runApp(const App());
}
