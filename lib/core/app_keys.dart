import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] for global SnackBars (sync / connectivity).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'rootMessenger');
