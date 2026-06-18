import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cobox_sv_mobile/features/authentication/presentation/pages/splash_page.dart';
import 'package:cobox_sv_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:cobox_sv_mobile/features/home/presentation/pages/home_page.dart';
import 'package:cobox_sv_mobile/features/planning/presentation/pages/planning_page.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/pages/routes_page.dart';
import 'package:cobox_sv_mobile/features/routes/presentation/pages/route_detail_page.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/pages/orders_page.dart';
import 'package:cobox_sv_mobile/features/orders/presentation/pages/order_detail_page.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/pages/incidents_page.dart';
import 'package:cobox_sv_mobile/features/incidents/presentation/pages/incident_detail_page.dart';
import 'package:cobox_sv_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/pages/vehicle_info_page.dart';
import 'package:cobox_sv_mobile/features/profile/presentation/pages/change_password_page.dart';
import 'package:cobox_sv_mobile/shared/widgets/bottom_nav_bar.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

GoRouter createRouter(AuthStatus authStatus) {
  // ignore: no_leading_underscores_for_local_identifiers
  final mockVehicle = VehicleEntity(
    id: '1',
    plate: 'ABC-1234',
    brand: 'Ford',
    model: 'F-350',
    year: 2022,
    type: 'Camión',
    color: 'Blanco',
    capacity: 3.5,
    fuelType: 'Diesel',
    lastMaintenance: DateTime(2026, 5, 15),
    nextMaintenance: DateTime(2026, 8, 15),
  );

  // ignore: no_leading_underscores_for_local_identifiers
  final mockProfile = ProfileEntity(
    id: '1',
    name: 'Carlos Rodríguez',
    email: 'carlos@coboxsv.com',
    phone: '+54 11 1234-5678',
    photoUrl: null,
    employeeId: 'EMP-001',
    licenseNumber: 'LIC-2026-12345',
    role: 'Conductor',
    isActive: true,
    vehicle: mockVehicle,
  );

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loggedIn = authStatus == AuthStatus.authenticated;
      final location = state.uri.toString();
      final isSplash = location == '/splash';
      final isLogin = location == '/login';

      if (authStatus == AuthStatus.unknown && !isSplash) {
        return '/splash';
      }
      if (!loggedIn && !isLogin && !isSplash) {
        return '/login';
      }
      if (loggedIn && isLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HomePage(),
                ),
              ),
              GoRoute(
                path: '/notifications',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const NotificationsPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.25, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planning',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const PlanningPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/routes',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const RoutesPage(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: RouteDetailPage(id: state.pathParameters['id']!),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/incidents',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const IncidentsPage(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: IncidentDetailPage(id: state.pathParameters['id']!),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const OrdersPage(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: OrderDetailPage(id: state.pathParameters['id']!),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ProfilePage(),
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: EditProfilePage(profile: mockProfile),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  GoRoute(
                    path: 'vehicle',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: VehicleInfoPage(vehicle: mockVehicle),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                  GoRoute(
                    path: 'password',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      key: state.pageKey,
                      child: const ChangePasswordPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.25, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('P\u00e1gina no encontrada', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentTab: AppTab.values[navigationShell.currentIndex],
        onTabSelected: (tab) {
          navigationShell.goBranch(
            tab.tabIndex,
            initialLocation: tab.tabIndex == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
