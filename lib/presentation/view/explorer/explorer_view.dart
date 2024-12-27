// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/search_provider.dart';

// Project imports:
import 'package:mug/presentation/provider/staker_provider.dart';
import 'package:mug/presentation/state/staker_state.dart';
import 'package:mug/presentation/widget/button_widget.dart';
import 'package:mug/routes/routes.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';
import 'package:mug/presentation/widget/common_padding.dart';

class ExplorerView extends ConsumerStatefulWidget {
  const ExplorerView({super.key});

  @override
  ConsumerState<ExplorerView> createState() => _ExplorerViewState();
}

class _ExplorerViewState extends ConsumerState<ExplorerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(stakerProvider.notifier).getStakers(0);
    });
  }

  final TextEditingController _searchText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Massa Explorer'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(stakerProvider.notifier).getStakers(0); //fixme: pass current page
          },
          child: Consumer(
            builder: (context, ref, child) {
              return switch (ref.watch(stakerProvider)) {
                StakerInitial() => const Text('No stakers.'),
                StakerLoading() => const CircularProgressIndicator(),
                StakersSuccess(stakers: final stakers) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  formatNumber(stakers.stakerNumbers.toDouble()),
                                  textAlign: TextAlign.center,
                                ),
                                subtitle: const Text("Stakers", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Text(formatNumber(stakers.totalRolls.toDouble()), textAlign: TextAlign.center),
                                subtitle: const Text("Rolls", textAlign: TextAlign.center),
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
                              child: TextField(
                                controller: _searchText,
                                onChanged: (value) {
                                  ref.read(stakerProvider.notifier).filterStakers(value);
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search address/block/operation/mns...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                style: const TextStyle(fontSize: 12.0),
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (stakers.stakers.isEmpty)
                        ButtonWidget(
                          isDarkTheme: true,
                          text: "Search",
                          onClicked: () async {
                            final searchType = ref.read(searchProvider.notifier).getSearchType(_searchText.text);
                            print('search type: ${searchType.name}');

                            switch (searchType) {
                              case SearchType.address:
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.address,
                                  arguments: _searchText.text,
                                );
                              case SearchType.block:
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.block,
                                  arguments: _searchText.text,
                                );
                              case SearchType.operation:
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.operation,
                                  arguments: _searchText.text,
                                );
                              case SearchType.mns:
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.domain,
                                  arguments: _searchText.text,
                                );
                              case SearchType.unknown:
                                //Container(child: const Text("Uknown body"));
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.notFound,
                                  arguments: _searchText.text,
                                );
                            }
                          },
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: stakers.stakers.length,
                          itemBuilder: (BuildContext context, int index) {
                            final staker = stakers.stakers[index];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  ExploreRoutes.address,
                                  arguments: staker.address,
                                );
                              },
                              child: Card(
                                child: ListTile(
                                  leading: Text(staker.rank.toString(), style: const TextStyle(fontSize: 14)),
                                  title: Text(
                                    shortenString(staker.address, 20),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Ownership: ${formatNumber4(staker.ownershipPercentage)} %"),
                                      Text("Est. Daily Reward: ${formatNumber2(staker.estimatedDailyReward)} MAS"),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(staker.rolls.toString(), style: const TextStyle(fontSize: 16)),
                                      const Text("rolls"),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                StakerFailure(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }
}
