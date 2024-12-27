// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mug/data/data_source/network/wallet_network_data_source_impl.dart';
import 'package:mug/data/model/wallet_model.dart';
import 'package:mug/data/repository/wallet_repository_impl.dart';
import 'package:mug/domain/usecase/wallet_use_case_impl.dart';
import 'package:mug/presentation/provider/dex_provider.dart';
import 'package:mug/presentation/provider/wallet_init_provider.dart';
import 'package:mug/presentation/provider/wallet_list_provider.dart';

// Project imports:
import 'package:mug/presentation/state/wallets_state.dart';
import 'package:mug/routes/routes_name.dart';
import 'package:mug/service/massa_icon/svg.dart';
import 'package:mug/service/provider.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/button_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletsView extends ConsumerWidget {
  const WalletsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletInitialState = ref.watch(walletInitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
      ),
      body: walletInitialState.when(
        data: (isInitialised) {
          if (!isInitialised) {
            return _NoWalletView(ref: ref);
          }
          return _WalletListView();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
            child: error.toString().contains("LateInitialzationError")
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text("Wallet imported/created successfully!"),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                        "An error has occured, please try again later or the report the issue to Massa Team: $error"),
                  )),
      ),
    );
  }
}

class _NoWalletView extends StatelessWidget {
  final WidgetRef ref;

  const _NoWalletView({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/mu.svg',
            height: 200,
            width: 200,
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(child: Text("It is so lonely here. Please create at least one address!xx")),
          ),
          const SizedBox(height: 40),
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
                  await ref.watch(walletInitProvider.notifier).createInitialWallet();
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('New Wallet'),
                iconAlignment: IconAlignment.start,
              ),
            ],
          )
        ],
      ),
      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     const Text(
      //       'No wallets exist.',
      //       style: TextStyle(fontSize: 16),
      //     ),
      //     const SizedBox(height: 20),
      //     ElevatedButton(
      //       onPressed: () async {
      //         try {
      //           await ref.read(walletInitProvider.notifier).createInitialWallet();
      //         } catch (e) {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             SnackBar(content: Text('Error creating new wallet: $e')),
      //           );
      //         }
      //       },
      //       child: const Text('Create Wallet'),
      //     ),
      //   ],
      // ),
    );
  }
}

class _WalletListView extends ConsumerWidget {
  const _WalletListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<WalletModel>>(
      future: ref.read(walletListProvider.notifier).loadWallets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(child: Text('No wallets found.'));
        } else if (snapshot.hasData) {
          final wallets = snapshot.data!;
          return ListView.builder(
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    WalletRoutes.account,
                    arguments: wallet.address,
                  );
                },
                child: Card(
                  child: ListTile(
                    // leading: StringIcon(
                    //   inputString: wallet.address,
                    //   iconSize: 50,
                    // ),

                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: generateRadial(wallet.address),
                      // child: AvatarGenerator(
                      //   seed: wallet.address,
                      //   tilePadding: 1.0,
                      //   colors: const [Colors.white70, Colors.black, Colors.blue],
                      // ),
                    ),
                    //leading: RandomAvatar(wallet.address, trBackground: true, height: 40, width: 40),
                    title: Text(
                      wallet.address.substring(wallet.address.length - 4),
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
          );
        } else {
          return const Center(child: Text('Unexpected error occurred.'));
        }
      },
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
                      print("private key: ${controller.text}");
                      await ref.read(walletInitProvider.notifier).importInitialWallet(controller.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wallet imported!')),
                      );
                      return Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error occured while importing your wallet!')),
                      );
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

// class _WalletListView extends StatelessWidget {
//   //final List<WalletModel> wallets;

//   const _WalletListView({required this.wallets});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: wallets.length,
//       itemBuilder: (context, index) {
//         final wallet = wallets[index];
//         return GestureDetector(
//           onTap: () async {
//             await Navigator.pushNamed(
//               context,
//               WalletRoutes.account,
//               arguments: wallet.address,
//             );
//           },
//           child: Card(
//             child: ListTile(
//               // leading: StringIcon(
//               //   inputString: wallet.address,
//               //   iconSize: 50,
//               // ),

//               leading: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: generateRadial(wallet.address),
//                 // child: AvatarGenerator(
//                 //   seed: wallet.address,
//                 //   tilePadding: 1.0,
//                 //   colors: const [Colors.white70, Colors.black, Colors.blue],
//                 // ),
//               ),
//               //leading: RandomAvatar(wallet.address, trBackground: true, height: 40, width: 40),
//               title: Text(
//                 wallet.address.substring(wallet.address.length - 4),
//                 style: const TextStyle(fontSize: 20),
//               ),
//               trailing: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "12.11", //formatNumber4(wallet.addressInformation!.finalBalance),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "MAS",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
