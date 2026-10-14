import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/core/push/firebase_push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebasePushService.instance.initialize();
  runApp(const MoviCreditoApp());
}
