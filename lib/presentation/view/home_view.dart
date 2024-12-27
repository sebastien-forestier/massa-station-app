// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/provider/dashboard_provider.dart';
import 'package:mug/presentation/view/explorer/explorer_view.dart';
import 'package:mug/presentation/view/dex/dex_view.dart';
import 'package:mug/presentation/view/settings/setting_view.dart';
import 'package:mug/presentation/view/wallet/wallets_view.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Home> {
  final listOfWidgets = [
    const WalletsView(),
    const DexView(),
    const ExplorerView(),
    const SettingView(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    return Scaffold(
      body: listOfWidgets.elementAt(state),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state,
        animationDuration: const Duration(milliseconds: 600),
        onDestinationSelected: (int index) {
          ref.read(dashboardProvider.notifier).changeIndexBottom(index: index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'WALLETS',
          ),
          NavigationDestination(
            icon: Icon(Icons.currency_exchange_outlined),
            label: 'DUSA DEX',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'EXPLORER',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}
