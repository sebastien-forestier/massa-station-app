// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/wallet_list_provider.dart';
import 'package:mug/presentation/widget/information_snack_message.dart';

// Project imports:
import 'package:mug/routes/routes_name.dart';
import 'package:mug/presentation/widget/massa_icon.dart';
import 'package:mug/utils/number_helpers.dart';

class WalletsView extends ConsumerWidget {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(walletListProvider.notifier).loadWallets();
        },
        child: walletState.when(
          data: (wallets) {
            if (wallets == null) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    "No wallet information retrieved, please try again later or the report the issue to Massa Team"),
              );
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(
                            "${formatNumber4(wallets.finalBalance)} MAS",
                            textAlign: TextAlign.center,
                          ),
                          subtitle: const Text("Total Balance", textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: Text(formatNumber(wallets.rolls.toDouble()), textAlign: TextAlign.center),
                          subtitle: const Text("Total Rolls", textAlign: TextAlign.center),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    //padding: const EdgeInsets.symmetric(vertical: 20),
                    height: 400,
                    child: ListView.builder(
                      itemCount: wallets.wallets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final wallet = wallets.wallets[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              WalletRoutes.wallet,
                              arguments: wallet.address,
                            );
                          },
                          child: Card(
                            child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: MassaIcon(wallet.address),
                              ),
                              title: Text(
                                wallet.name ?? wallet.address.substring(wallet.address.length - 4),
                                style: const TextStyle(fontSize: 20),
                              ),
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatNumber4(wallet.addressInformation!.finalBalance),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "MAS",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => const _ImportWalletBottomSheet(),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Import Wallet'),
                      iconAlignment: IconAlignment.start,
                    ),
                    const SizedBox(width: 10.0),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await ref.watch(walletListProvider.notifier).createNewWallet();
                      },
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('New Wallet'),
                      iconAlignment: IconAlignment.start,
                    ),
                  ],
                )
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("An error has occured, please try again later or the report the issue to Massa Team"),
          )),
        ),
      ),
    );
  }
}

class _ImportWalletBottomSheet extends ConsumerWidget {
  const _ImportWalletBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("IMPORT WALLET", style: TextStyle(fontSize: 20, color: Colors.blue)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Wallet Address',
                ),
              ),
              const SizedBox(height: 16.0),
              FilledButton.tonalIcon(
                onPressed: () async {
                  if (controller.text.isNotEmpty) {
                    try {
                      await ref.read(walletListProvider.notifier).importExistingWallet(controller.text);
                      informationSnackBarMessage(context, 'Wallet imported!');
                      return Navigator.of(context).pop();
                    } catch (e) {
                      informationSnackBarMessage(context, 'Error occured while importing your wallet!');
                      return Navigator.of(context).pop();
                    }
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Wallet'),
                iconAlignment: IconAlignment.start,
              ),
            ],
          ),
        ));
  }
}
