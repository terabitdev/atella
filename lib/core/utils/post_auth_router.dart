import 'package:firebase_auth/firebase_auth.dart';
import 'package:atella/Routes/app_routes.dart';

/// Decides where a signed-in user should land: the regular customer app
/// shell, or the supplier home, based on the `role` custom claim set by
/// acceptSupplierInvite / bootstrapAdmin. Falls back to the customer shell
/// on any error so a claims hiccup never locks a real user out.
Future<String> resolvePostAuthRoute() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return AppRoutes.onboarding;

  try {
    final tokenResult = await user.getIdTokenResult();
    final role = tokenResult.claims?['role'];
    if (role == 'supplier') return AppRoutes.supplierHome;
    return AppRoutes.navBar;
  } catch (_) {
    return AppRoutes.navBar;
  }
}
