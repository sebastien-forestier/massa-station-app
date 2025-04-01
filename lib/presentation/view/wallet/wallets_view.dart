// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/wallet_list_provider.dart';
import 'package:mug/presentation/view/wallet/wallet_view.dart';

// Project imports:
import 'package:mug/routes/routes_name.dart';
import 'package:mug/presentation/widget/widget.dart';
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
            if (wallets!.wallets.isEmpty) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        "It is very lonely here! No wallet found! You can create a new wallet or import an existing wallet."),
                  ),
                  _addImport(context, ref)
                ],
              );
            }
            return Column(
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
                  child: ListView.builder(
                    itemCount: wallets.wallets.length,
                    itemBuilder: (BuildContext context, int index) {
                      final wallet = wallets.wallets[index];
                      return GestureDetector(
                        onTap: () async {
                          final hasBalance =
                              wallet.addressInformation!.finalBalance >= ref.read(settingProvider).feeAmount;
                          final WalletViewArg walletViewArg = WalletViewArg(wallet.address, hasBalance);
                          await Navigator.pushNamed(
                            context,
                            WalletRoutes.wallet,
                            arguments: walletViewArg,
                          );
                        },
                        child: Card(
                          child: ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: AddressIcon(wallet.address),
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
                _addImport(context, ref)
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: Text("An error has occurred, please try again later or report the issue to Massa Team"),
          )),
        ),
      ),
    );
  }

  Row _addImport(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilledButton.tonalIcon(
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
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
    );
  }
}

class _ImportWalletBottomSheet extends ConsumerWidget {
  const _ImportWalletBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Adjust for keyboard
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("IMPORT WALLET", style: TextStyle(fontSize: 20, color: Colors.blue)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter wallet private key',
              ),
            ),
            const SizedBox(height: 16.0),
            FilledButton.tonalIcon(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    final isExisting = await ref.read(walletListProvider.notifier).isWalletExisting(controller.text);
                    if (isExisting) {
                      if (context.mounted) {
                        informationSnackBarMessage(context, 'Wallet already exists!');
                        Navigator.of(context).pop();
                      }
                    } else {
                      await ref.read(walletListProvider.notifier).importExistingWallet(controller.text);
                      if (context.mounted) {
                        informationSnackBarMessage(context, 'Wallet imported!');
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      informationSnackBarMessage(
                          context, 'Error occurred while importing your wallet! The wallet probably already exists!');
                      Navigator.of(context).pop();
                    }
                  }
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Wallet'),
              iconAlignment: IconAlignment.start,
            ),
          ],
        ),
      ),
    );
  }
}
