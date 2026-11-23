import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staki_mobile/core/router/app_routes.dart';
import 'package:staki_mobile/core/theme/app_icons.dart';
import 'package:staki_mobile/presentation/features/marketplace/market_routes.dart';
import 'package:staki_mobile/presentation/shared_widgets/shared_widgets.dart';

const borrowerTabs = [
  BottomNavItem(label: 'Home', icon: AppIcons.house),
  BottomNavItem(label: 'Passport', icon: AppIcons.gauge),
  BottomNavItem(label: 'Loans', icon: AppIcons.money),
  BottomNavItem(label: 'Profile', icon: AppIcons.user),
];

const lenderTabs = [
  BottomNavItem(label: 'Marketplace', icon: AppIcons.storefront),
  BottomNavItem(label: 'Portfolio', icon: AppIcons.chartBar),
  BottomNavItem(label: 'Wallet', icon: AppIcons.wallet),
  BottomNavItem(label: 'Profile', icon: AppIcons.user),
];

/// The first screen of each tab. These show no back arrow.
const tabRootPaths = {
  AppRoutes.home,
  AppRoutes.creditPassport,
  AppRoutes.myLoans,
  AppRoutes.profile,
  MarketRoutes.base,
  MarketRoutes.portfolio,
  MarketRoutes.ledger,
  AppRoutes.lenderProfile,
};

/// True when [context] is the first screen of a bottom tab. False when
/// there is no router (for example a page tested on its own).
bool isTabRoot(BuildContext context) =>
    GoRouter.maybeOf(context) != null &&
    tabRootPaths.contains(GoRouterState.of(context).uri.path);

/// Frame around the signed-in screens: the current tab plus the bottom bar.
/// Each tab keeps its own history, so switching tabs and pressing back
/// behave as expected.
class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    required this.items,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<BottomNavItem> items;

  void _select(int index) => navigationShell.goBranch(
        index,
        // Tapping the current tab again returns to its first screen.
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    return PopScope(
      // On any tab but the first, Android back goes to the first tab
      // instead of closing the app.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && index != 0) _select(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          items: items,
          selectedIndex: index,
          onChanged: _select,
        ),
      ),
    );
  }
}
