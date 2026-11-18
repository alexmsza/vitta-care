import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/models/conversation.dart';
import '../core/models/on_demand_request.dart';
import '../core/models/shift.dart';
import '../core/models/user.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/professional/presentation/screens/professional_dashboard_screen.dart';
import '../features/professional/presentation/screens/service_request_detail_screen.dart';
import '../features/professional/presentation/screens/shift_detail_screen.dart';
import '../features/family/presentation/screens/family_dashboard_screen.dart';
import '../features/family/presentation/screens/request_detail_screen.dart';
import '../features/profile/presentation/screens/profile_edit_screen.dart';
import '../features/family/presentation/screens/family_profile_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/screens/conversations_screen.dart';
import '../features/faq/presentation/screens/faq_screen.dart';
import '../features/family/presentation/screens/history_screen.dart';
import '../features/family/presentation/screens/clinical_record_screen.dart';
import '../features/common/presentation/screens/rating_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod auth state changes into GoRouter's refreshListenable.
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<AppUser?>(authStateProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user = _ref.read(authStateProvider);
    final isLoggedIn = user != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';

    if (isLoggedIn && isAuthRoute) {
      return switch (user.role) {
        'professional' => '/professional',
        _ => '/family',
      };
    }

    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/professional',
        builder: (context, state) => const ProfessionalDashboard(),
      ),
      GoRoute(
        path: '/family',
        builder: (context, state) => const FamilyDashboard(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final user = ref.watch(authStateProvider);
            return user?.role == 'family'
                ? const FamilyProfileScreen()
                : const ProfileEditScreen();
          },
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final conversationId =
              int.parse(state.pathParameters['conversationId'] ?? '0');
          final conv = state.extra as Conversation?;
          return ChatScreen(
              conversationId: conversationId, conversation: conv);
        },
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/clinical-record',
        builder: (context, state) => const ClinicalRecordScreen(),
      ),
      GoRoute(
        path: '/rating',
        builder: (context, state) {
          final targetName = state.extra as String? ?? 'Profissional Vitta';
          return RatingScreen(patientName: targetName);
        },
      ),
      GoRoute(
        path: '/shift-detail',
        builder: (context, state) {
          final shift = state.extra as Shift;
          return ShiftDetailScreen(shift: shift);
        },
      ),
      GoRoute(
        path: '/request-detail',
        builder: (context, state) {
          final request = state.extra as OnDemandRequest;
          return RequestDetailScreen(request: request);
        },
      ),
      GoRoute(
        path: '/professional-request-detail',
        builder: (context, state) {
          final request = state.extra as OnDemandRequest;
          return ProfessionalServiceRequestDetailScreen(request: request);
        },
      ),
    ],
  );
});
