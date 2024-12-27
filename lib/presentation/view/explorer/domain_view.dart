// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:mug/presentation/provider/domain_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/state/domain_state.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/label_card.dart';
import 'package:mug/presentation/widget/no_search_result_widget.dart';
import 'package:mug/presentation/widget/short_card.dart';

class DomainView extends ConsumerStatefulWidget {
  final String domainName;
  const DomainView(this.domainName, {super.key});

  @override
  ConsumerState<DomainView> createState() => _DomainViewState();
}

class _DomainViewState extends ConsumerState<DomainView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(domainProvider.notifier).getDomain(widget.domainName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Domain Details'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(domainProvider.notifier).getDomain(widget.domainName);
          },
          child: Consumer(
            builder: (context, ref, child) {
              var isDarkTheme = ref.watch(settingProvider).darkTheme;
              return switch (ref.watch(domainProvider)) {
                DomainInitial() => const Text('Domain information is loading....'),
                DomainLoading() => const CircularProgressIndicator(),
                DomainSuccess(domainEntity: final domainEntry) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      LabelCard(
                        labelText: "Owner Address",
                        valueText: domainEntry.ownerAddress,
                        leadingIcon: const Icon(Icons.person, size: 30),
                      ),
                      LabelCard(
                        labelText: "Target Address",
                        valueText: domainEntry.targetAddress,
                        leadingIcon: const Icon(Icons.gps_fixed, size: 30),
                      ),
                      ShortCard(
                        labelText: "Token ID",
                        valueText: domainEntry.tokenId,
                        leadingIcon: const Icon(Icons.local_offer, size: 30),
                      ),
                    ],
                  ),
                DomainFailure(message: final message) => message.contains("data")
                    ? NoSearchResult(
                        searchText: widget.domainName,
                      )
                    : const Text("something went wrong")
              };
            },
          ),
        ),
      ),
    );
  }
}
