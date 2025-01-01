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
import 'package:mug/presentation/widget/information_snack_message.dart';
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Address Details'),
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
                                    colors: const [Colors.white70, Colors.black, Colors.blue],
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
                                          informationSnackBarMessage(context, "Address copied!");
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
