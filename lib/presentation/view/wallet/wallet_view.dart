// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/provider/wallet_provider.dart';
import 'package:mug/presentation/state/wallets_state.dart';
import 'package:mug/routes/routes_name.dart';
import 'package:mug/service/massa_icon/svg.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/button_widget.dart';

class WalletView extends ConsumerStatefulWidget {
  const WalletView({super.key});

  @override
  ConsumerState<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends ConsumerState<WalletView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(walletProvider.notifier).loadWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Wallets'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(walletProvider.notifier).loadWallets();
          },
          child: Consumer(
            builder: (context, ref, child) {
              //final isDarkTheme = ref.watch(settingProvider).darkTheme;
              return switch (ref.watch(walletProvider)) {
                WalletInitial() => const Text('List is empty.'),
                WalletLoading() => const CircularProgressIndicator(),
                WalletEmpty(message: final message) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(message),
                      const SizedBox(
                        height: 20,
                      ),
                      ButtonWidget(
                        isDarkTheme: true,
                        text: "New Wallet",
                        onClicked: () async {
                          await ref.watch(walletProvider.notifier).createWallet();
                        },
                      )
                    ],
                  ),
                WalletSuccess(wallets: final wallets) => Text("Nothing new here!"),
                // WalletSuccess(wallets: final wallets) => Column(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Expanded(
                //             child: Card(
                //               child: ListTile(
                //                 title: Text(
                //                   "${formatNumber4(wallets.finalBalance)} MAS",
                //                   textAlign: TextAlign.center,
                //                 ),
                //                 subtitle: const Text("Total Balance", textAlign: TextAlign.center),
                //               ),
                //             ),
                //           ),
                //           Expanded(
                //             child: Card(
                //               child: ListTile(
                //                 title: Text(formatNumber(wallets.rolls.toDouble()), textAlign: TextAlign.center),
                //                 subtitle: const Text("Total Rolls", textAlign: TextAlign.center),
                //               ),
                //             ),
                //           )
                //         ],
                //       ),
                //       Container(
                //         margin: const EdgeInsets.symmetric(vertical: 20),
                //         //padding: const EdgeInsets.symmetric(vertical: 20),
                //         height: 400,
                //         child: ListView.builder(
                //           scrollDirection: Axis.vertical,
                //           physics: const PageScrollPhysics(),
                //           itemCount: wallets.wallets.length,
                //           itemBuilder: (BuildContext context, int index) {
                //             final wallet = wallets.wallets[index];
                //             return GestureDetector(
                //               onTap: () async {
                //                 await Navigator.pushNamed(
                //                   context,
                //                   WalletRoutes.account,
                //                   arguments: wallet.address,
                //                 );
                //               },
                //               child: Card(
                //                 child: ListTile(
                //                   // leading: StringIcon(
                //                   //   inputString: wallet.address,
                //                   //   iconSize: 50,
                //                   // ),

                //                   leading: SizedBox(
                //                     width: 50,
                //                     height: 50,
                //                     child: generateRadial(wallet.address),
                //                     // child: AvatarGenerator(
                //                     //   seed: wallet.address,
                //                     //   tilePadding: 1.0,
                //                     //   colors: const [Colors.white70, Colors.black, Colors.blue],
                //                     // ),
                //                   ),
                //                   //leading: RandomAvatar(wallet.address, trBackground: true, height: 40, width: 40),
                //                   title: Text(
                //                     wallet.address.substring(wallet.address.length - 4),
                //                     style: const TextStyle(fontSize: 20),
                //                   ),
                //                   trailing: Row(
                //                     mainAxisAlignment: MainAxisAlignment.end,
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     mainAxisSize: MainAxisSize.min,
                //                     children: [
                //                       Text(
                //                         formatNumber4(wallet.addressInformation!.finalBalance),
                //                         textAlign: TextAlign.center,
                //                         style: const TextStyle(fontSize: 16),
                //                       ),
                //                       const SizedBox(width: 10),
                //                       const Text(
                //                         "MAS",
                //                         style: TextStyle(fontSize: 16),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             );
                //           },
                //         ),
                //       ),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Expanded(
                //             child: ButtonWidget(
                //               isDarkTheme: true,
                //               text: "Import Wallet",
                //               onClicked: () => _showBottomSheet(context),
                //             ),
                //           ),
                //           const SizedBox(width: 10.0),
                //           Expanded(
                //             child: ButtonWidget(
                //               isDarkTheme: true,
                //               text: "New Wallet",
                //               onClicked: () async {
                //                 await ref.watch(walletProvider.notifier).createWallet();
                //               },
                //             ),
                //           ),
                //         ],
                //       )
                //     ],
                //   ),
                WalletFailure(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(onSubmit: (String value) {
          // Handle the submitted text here
          ref.read(walletProvider.notifier).importWallet(value);
          print('Submitted text: $value');
          Navigator.pop(context); // Close the bottom sheet
        });
      },
    );
  }

  Future<String?> importWalletModelBottomSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Allow the BottomSheet to resize
      builder: (BuildContext context) {
        final TextEditingController walletController = TextEditingController();

        return SizedBox(
          height: 400,
          child: SingleChildScrollView(
            // Allow scrolling if the content exceeds height
            child: Padding(
              // padding: const EdgeInsets.all(16.0),
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
                children: <Widget>[
                  const Text(
                    'Import Wallet',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    autocorrect: false,
                    controller: walletController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Wallet Address',
                    ),
                    keyboardType: TextInputType.text, // Specify keyboard type
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final enteredWalletAddress = walletController.text;
                      // Pass the wallet address back to the calling context
                      Navigator.of(context).pop(enteredWalletAddress);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showQRCodeModelBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          //color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'This is a BottomSheet',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close BottomSheet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _deleteWallet() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Confirm'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Are you sure you want to delete this wallet?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }
}

class BottomSheetContent extends StatefulWidget {
  final Function(String) onSubmit;

  const BottomSheetContent({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      //padding: const EdgeInsets.all(16.0),
      padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Wallet Address',
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              widget.onSubmit(_controller.text); // Pass the text to the calling function
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
