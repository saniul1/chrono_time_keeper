import 'dart:async';

import 'package:chrono_time_keeper/before_run.dart';
import 'package:flutter/material.dart';

import 'app.dart';

FutureOr<void> main() async {
  await beforeRun();
  runApp(const App());
}
