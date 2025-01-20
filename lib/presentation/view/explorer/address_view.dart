// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:massa/massa.dart';
import 'package:mug/data/model/transaction_history.dart';

// Project imports:
import 'package:mug/presentation/provider/address_provider.dart';
import 'package:mug/presentation/provider/wallet_provider.dart';
import 'package:mug/presentation/state/address_state.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/information_snack_message.dart';
import 'package:mug/presentation/widget/massa_icon.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart' as ht;

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
            return ref.read(addressProvider.notifier).getAddress(widget.address, true);
          },
          child: Consumer(
            builder: (context, ref, child) {
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
                                leading: SizedBox(width: 40, height: 40, child: MassaIcon(addressEntity.address)),
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
                      // Tabs for Assets and Transactions
                      Expanded(
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              const TabBar(
                                tabs: [
                                  Tab(text: 'TOKENS'),
                                  Tab(text: 'TRANSACTIONS'),
                                ],
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                //labelStyle: TextStyle(fontSize: 14),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // Assets Tab
                                    ListView.builder(
                                      padding: const EdgeInsets.all(16.0),
                                      itemCount: addressEntity.tokenBalances?.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              leading: SvgPicture.asset(addressEntity.tokenBalances![index].iconPath,
                                                  semanticsLabel: addressEntity.tokenBalances?[index].name.name,
                                                  height: 40.0,
                                                  width: 40.0),
                                              title: Text(
                                                '${addressEntity.tokenBalances?[index].balance}  ${addressEntity.tokenBalances?[index].name.name}',
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Divider(thickness: 0.5, color: Colors.brown[500]),
                                          ],
                                        );
                                      },
                                    ),

                                    if (addressEntity.transactionHistory != null)
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ht.HorizontalDataTable(
                                          leftHandSideColumnWidth: 100,
                                          rightHandSideColumnWidth: 700,
                                          isFixedHeader: true,
                                          leftHandSideColBackgroundColor: Theme.of(context).canvasColor,
                                          rightHandSideColBackgroundColor: Theme.of(context).canvasColor,
                                          headerWidgets: [
                                            _buildHeaderItem('Hash', 100),
                                            _buildHeaderItem('Age', 110),
                                            _buildHeaderItem('Status', 70),
                                            _buildHeaderItem('Type', 100),
                                            _buildHeaderItem('From', 110),
                                            _buildHeaderItem('To', 110),
                                            _buildHeaderItem('Amount', 120),
                                            _buildHeaderItem('Fee', 80),
                                          ],
                                          leftSideItemBuilder: (context, index) {
                                            final history = addressEntity.transactionHistory?.combinedHistory?[index];
                                            return _buildLeftSideItem(shortenString(history!.hash!, 10), index);
                                          },
                                          rightSideItemBuilder: (context, index) {
                                            final history = addressEntity.transactionHistory?.combinedHistory?[index];
                                            return _buildRightSideItem(history!, index);
                                          },
                                          itemCount: addressEntity.transactionHistory!.combinedHistory!.length,
                                        ),
                                      ),
                                    if (addressEntity.transactionHistory == null)
                                      const Text("No transaction history found"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildHeaderItem(String label, double width) {
    return Container(
      width: width,
      height: 56,
      //color: Colors.blue,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(
          bottom: BorderSide(color: Colors.brown[900]!, width: 0.1),
        ),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSideItem(String text, int index) {
    return Container(
      width: 100,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[900] : Colors.grey[800],
        border: Border(
          bottom: BorderSide(color: Colors.brown[900]!, width: 0.1),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRightSideItem(TransactionHistory history, int index) {
    return Row(
      children: [
        _buildRightItem(
            ref.read(walletProvider.notifier).computeTimestampAge(int.parse(history.blockTime!)), 110, index),
        _buildRightItem(history.status!, 70, index),
        _buildRightItem(history.type!, 100, index),
        _buildRightItem(shortenString(history.from!, 12), 110, index),
        _buildRightItem(shortenString(history.to!, 12), 110, index),
        _buildRightItem('${toMAS(BigInt.parse(history.value!))} MAS', 120, index),
        _buildRightItem('${toMAS(BigInt.parse(history.transactionFee!))} MAS', 80, index),
      ],
    );
  }

  Widget _buildRightItem(String text, double width, int index) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[900] : Colors.grey[800],
        border: Border(
          bottom: BorderSide(color: Colors.brown[900]!, width: 0.1),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
