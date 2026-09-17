import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth_gateway/presentation/screens/entry_gateway_screen.dart';
import '../../features/lender_portal/presentation/screens/lender_portal_shell.dart';
import '../../features/borrower_portal/presentation/screens/borrower_portal_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const EntryGatewayScreen(),
      ),
      GoRoute(
        path: '/lender',
        builder: (context, state) => const LenderPortalShell(),
      ),
      GoRoute(
        path: '/borrower',
        builder: (context, state) => const BorrowerPortalShell(),
      ),
    ],
  );
});