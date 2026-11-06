
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  await di.initDependencies();

  runApp(const SchoolAdmissionApp());
}

class SchoolAdmissionApp extends StatefulWidget {
  const SchoolAdmissionApp({super.key});

  @override
  State<SchoolAdmissionApp> createState() =>
      _SchoolAdmissionAppState();
}

class _SchoolAdmissionAppState extends State<SchoolAdmissionApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    // Get the shared authentication BLoC.
    _authBloc = di.sl<AuthBloc>();

    // Create the router and subscribe to BLoC changes first.
    _router = createRouter(_authBloc);

    // Start authentication checking after the router is ready.
    _authBloc.add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _router.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'School Admission',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
