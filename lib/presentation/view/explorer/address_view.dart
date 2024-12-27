// Flutter imports:
import 'package:avatar_generator/avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/provider/address_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/wallet_provider.dart';
import 'package:mug/presentation/state/address_state.dart';
import 'package:mug/presentation/widget/button_widget.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/snack_message.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';

class AddressView extends ConsumerStatefulWidget {
  final String address;
  const AddressView(this.address, {super.key});

  @override
  ConsumerState<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends ConsumerState<AddressView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(addressProvider.notifier).getAddress(widget.address, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAccount = ref.read(walletProvider.notifier).isAccountExisting(widget.address);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: isAccount.$1 ? const Text('Account Details') : const Text('Address Details'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(addressProvider.notifier).getAddress(widget.address, false);
          },
          child: Consumer(
            builder: (context, ref, child) {
              var isDarkTheme = ref.watch(settingProvider).darkTheme;
              return switch (ref.watch(addressProvider)) {
                AddressInitial() => const Text('Address information is loading....'),
                AddressLoading() => const CircularProgressIndicator(),
                AddressSuccess(addressEntity: final addressEntity) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: AvatarGenerator(
                                    seed: addressEntity.address,
                                    tilePadding: 2.0,
                                    colors: [Colors.white70, Colors.black, Colors.blue],
                                  ),
                                ),
                                title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(
                                    shortenString(addressEntity.address, 24),
                                    textAlign: TextAlign.left,
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: addressEntity.address)).then((result) {
                                          //if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('Address copied'),
                                          ));
                                        });
                                      },
                                      icon: const Icon(Icons.copy)),
                                ]),
                                subtitle:
                                    Text("Threat: ${addressEntity.thread.toString()}", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   // crossAxisAlignment: CrossAxisAlignment.stretch,
                      //   children: [
                      //     Expanded(
                      //       child: Card(
                      //         child: Column(mainAxisSize: MainAxisSize.min, children: [
                      //           // QrImageView(
                      //           //   data: addressEntity.address,
                      //           //   version: QrVersions.auto,
                      //           //   //backgroundColor:
                      //           //   eyeStyle: QrEyeStyle(
                      //           //       color: (isDarkTheme == true) ? Colors.white : Colors.black,
                      //           //       eyeShape: QrEyeShape.circle),
                      //           //   dataModuleStyle: QrDataModuleStyle(
                      //           //     color: (isDarkTheme == true) ? Colors.white : Colors.black,
                      //           //   ),
                      //           //   size: 180.0,
                      //           // ),
                      //           RandomAvatar(addressEntity.address, trBackground: true, height: 80, width: 80),
                      //           ListTile(
                      //             title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      //               Text(
                      //                 shortenString(addressEntity.address, 24),
                      //                 textAlign: TextAlign.left,
                      //               ),
                      //               IconButton(
                      //                   onPressed: () {
                      //                     Clipboard.setData(ClipboardData(text: addressEntity.address)).then((result) {
                      //                       //if (!mounted) return;
                      //                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      //                         content: Text('Address copied'),
                      //                       ));
                      //                     });
                      //                   },
                      //                   icon: const Icon(Icons.copy)),
                      //             ]),
                      //             subtitle:
                      //                 Text("Threat: ${addressEntity.thread.toString()}", textAlign: TextAlign.center),
                      //           ),
                      //         ]),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: const Text(
                                  "Total Assest",
                                  style: TextStyle(fontSize: 16),
                                ),
                                title: Text(
                                  formatNumber4(addressEntity.finalBalance + addressEntity.finalRolls * 100.00),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: const Text("MASSA", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(formatNumber4(addressEntity.finalBalance), textAlign: TextAlign.center),
                                subtitle: const Text("Final Balance", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(formatNumber4(addressEntity.candidateBalance), textAlign: TextAlign.center),
                                subtitle: const Text("Candidate Balance", textAlign: TextAlign.center),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  formatNumber(addressEntity.finalRolls.toDouble()),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: const Text("Final Rolls", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  formatNumber(addressEntity.candidateRolls.toDouble()),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: const Text("Candidate Rolls", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isAccount.$1)
                        ButtonWidget(
                          isDarkTheme: isDarkTheme,
                          text: "Set as Default Account",
                          onClicked: () {
                            final isSet = ref.read(walletProvider.notifier).setDefaultAccount(widget.address);
                            if (isSet) {
                              showSnackBarMessage(context, "${widget.address} is set as a default account");
                            }
                          },
                        )
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   // crossAxisAlignment: CrossAxisAlignment.stretch,
                      //   children: [
                      //     Expanded(
                      //       child: Card(
                      //         child: ListTile(
                      //           title: Text(formatNumber4(widget.staker.estimatedDailyReward),
                      //               textAlign: TextAlign.center),
                      //           subtitle: const Text("Est. Daily Reward", textAlign: TextAlign.center),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Card(
                      //         child: ListTile(
                      //           title: Text("${formatNumber4(widget.staker.ownershipPercentage)} %",
                      //               textAlign: TextAlign.center),
                      //           subtitle: const Text("Ownerships", textAlign: TextAlign.center),
                      //         ),
                      //       ),
                      //     )
                      //   ],
                      // ),
                    ],
                  ),
                AddressFailure(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }
}
