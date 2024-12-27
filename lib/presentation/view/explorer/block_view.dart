// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/provider/block_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/state/block_state.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/label_card.dart';
import 'package:mug/presentation/widget/short_card.dart';
import 'package:mug/utils/string_helpers.dart';

class BlockView extends ConsumerStatefulWidget {
  final String blockHash;
  const BlockView(this.blockHash, {super.key});

  @override
  ConsumerState<BlockView> createState() => _BlockViewState();
}

class _BlockViewState extends ConsumerState<BlockView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(blockProvider.notifier).getBlock(widget.blockHash);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Block Details'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(blockProvider.notifier).getBlock(widget.blockHash);
          },
          child: Consumer(
            builder: (context, ref, child) {
              var isDarkTheme = ref.watch(settingProvider).darkTheme;
              return switch (ref.watch(blockProvider)) {
                BlockInitial() => const Text('Block information is loading....'),
                BlockLoading() => const CircularProgressIndicator(),
                BlockSuccess(blockEntity: final blockEntity) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      LabelCard(
                          labelText: "Block ID",
                          valueText: blockEntity.hash!,
                          leadingIcon: const Icon(Icons.layers, size: 24)),
                      LabelCard(
                          labelText: "Block Producer",
                          valueText: blockEntity.creatorAddress!,
                          leadingIcon: const Icon(Icons.developer_mode, size: 24)),
                      ShortCard(
                          labelText: "Block Time",
                          valueText: blockEntity.blockTime!,
                          leadingIcon: const Icon(Icons.timer, size: 24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child:
                                ShortCard(labelText: "Status", valueText: blockEntity.isFinal! ? "Final" : "Pending"),
                          ),
                          Expanded(
                              child:
                                  ShortCard(labelText: "Operations", valueText: blockEntity.operationCount!.toString()))
                        ],
                      ),
                      ShortCard(
                          labelText: "Endorsements",
                          valueText: blockEntity.endorsements!.toString(),
                          leadingIcon: const Icon(Icons.check_circle, size: 24)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ShortCard(labelText: "Threads", valueText: blockEntity.thread!.toString()),
                          ),
                          Expanded(
                              child: ShortCard(labelText: "Parents", valueText: blockEntity.parents!.length.toString()))
                        ],
                      ),
                      ShortCard(
                        labelText: "Block Size",
                        valueText: "${blockEntity.blockSize!} B",
                        leadingIcon: const Icon(Icons.storage, size: 24),
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Expanded(
                      //       child: Card(
                      //         child: ListTile(
                      //           title: Text(
                      //             formatNumber(address.finalRolls.toDouble()),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //           subtitle: const Text("Final Rolls", textAlign: TextAlign.center),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Card(
                      //         child: ListTile(
                      //           title: Text(
                      //             formatNumber(address.candidateRolls.toDouble()),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //           subtitle: const Text("Candidate Rolls", textAlign: TextAlign.center),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
                BlockFailure(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }
}
