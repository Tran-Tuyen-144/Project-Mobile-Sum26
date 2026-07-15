import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PetHubApp());
}

class PetHubApp extends StatefulWidget {
  const PetHubApp({super.key});

  @override
  State<PetHubApp> createState() => _PetHubAppState();
}

class _PetHubAppState extends State<PetHubApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();
    _listenDeepLinks();
  }

  void _listenDeepLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (Object error) {
        debugPrint('Deep link error: $error');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    final String route = _convertUriToRoute(uri);

    debugPrint('Deep link received: $uri');
    debugPrint('Navigate to: $route');

    appRouter.go(route);
  }

  String _convertUriToRoute(Uri uri) {
    final String target = uri.host.isNotEmpty
        ? uri.host
        : uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : '';

    switch (target) {
      case 'customer':
        return '/customer';

      case 'booking':
        return '/booking';

      case 'service':
        return '/service';

      case 'services':
        return '/services';

      case 'map':
        return '/map';

      case 'community':
        return '/community';

      default:
        return '/';
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
