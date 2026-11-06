import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/parent/presentation/screens/parent_dashboard_screen.dart';
import 'features/parent/presentation/screens/student_admission_screen.dart';
import 'features/parent/presentation/screens/my_applications_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/manage_exam_slots_screen.dart';
import 'features/parent/presentation/screens/available_exam_slots_screen.dart';
import 'features/admin/presentation/screens/admin_exam_bookings_screen.dart';
import 'features/admin/presentation/screens/update_score_screen.dart';
import 'features/parent/presentation/screens/registration_fee_screen.dart';

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.primaryLight),
            const SizedBox(height: 20),
            Text(title, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  final refreshNotifier = _AuthRouterRefresh(authBloc);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteConstants.splash,
    refreshListenable: refreshNotifier,

    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;

      final isPublicRoute =
          location == RouteConstants.splash ||
          location == RouteConstants.login ||
          location == RouteConstants.register;

      // Wait while authentication is being checked.
      if (authState is AuthInitial || authState is AuthLoading) {
        return location == RouteConstants.splash ? null : RouteConstants.splash;
      }

      // Keep the current page while logout is processing.
      if (authState is AuthLoggingOut) {
        return null;
      }

      // Preserve the dashboard if an operation failed for a signed-in user.
      if (authState is AuthError && authState.previousUser != null) {
        return null;
      }

      // Unauthenticated users can only access public pages.

      if (authState is Unauthenticated ||
          (authState is AuthError && authState.previousUser == null)) {
        if (location == RouteConstants.register ||
            location == RouteConstants.login) {
          return null;
        }

        return RouteConstants.login;
      }

      if (authState is Authenticated) {
        final user = authState.user;

        // Admin accounts must stay within admin routes.
        if (user.role == AppConstants.roleAdmin) {
          if (location.startsWith('/parent')) {
            return RouteConstants.adminDashboard;
          }

          if (isPublicRoute) {
            return RouteConstants.adminDashboard;
          }
        }

        // Parent accounts must stay within parent routes.
        if (user.role == AppConstants.roleParent) {
          if (location.startsWith('/admin')) {
            return RouteConstants.parentDashboard;
          }

          if (isPublicRoute) {
            return RouteConstants.parentDashboard;
          }
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteConstants.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Parent routes
      GoRoute(
        path: RouteConstants.parentDashboard,
        name: 'parentDashboard',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.createStudent,
        name: 'createStudent',

        builder: (context, state) => const StudentAdmissionScreen(),
      ),
      GoRoute(
        path: RouteConstants.myApplications,
        name: 'myApplications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: RouteConstants.studentDetail,
        name: 'studentDetail',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Student Detail',
          icon: Icons.person_rounded,
        ),
      ),
      GoRoute(
        path: RouteConstants.editStudent,
        name: 'editStudent',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Edit Application',
          icon: Icons.edit_rounded,
        ),
      ),
      GoRoute(
        path: RouteConstants.payment,
        name: 'payment',
        builder: (context, state) => RegistrationFeeScreen(
          studentId: state.pathParameters['studentId']!,
        ),
      ),  
      GoRoute(
        path: RouteConstants.slotBooking,
        name: 'slotBooking',
        builder: (context, state) => const AvailableExamSlotsScreen(),
      ),

      // Admin routes
      GoRoute(
        path: RouteConstants.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminStudentDetail,
        name: 'adminStudentDetail',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Student Detail (Admin)',
          icon: Icons.person_search_rounded,
        ),
      ),
      GoRoute(
        path: RouteConstants.updateScore,
        name: 'updateScore',
        builder: (context, state) =>
            UpdateScoreScreen(studentId: state.pathParameters['studentId']!),
      ),
      GoRoute(
        path: RouteConstants.assignCourse,
        name: 'assignCourse',
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Assign Course',
          icon: Icons.school_rounded,
        ),
      ),
      GoRoute(
        path: RouteConstants.manageSlots,
        name: 'manageSlots',
        builder: (context, state) => const ManageExamSlotsScreen(),
      ),
      GoRoute(
        path: RouteConstants.adminExamBookings,
        name: 'adminExamBookings',
        builder: (context, state) => const AdminExamBookingsScreen(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text('Page Not Found', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'The route does not exist.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.go(RouteConstants.splash),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
