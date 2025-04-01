// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart' as ht;
import 'package:mug/constants/constants.dart';

// Project imports:
import 'package:mug/presentation/provider/screen_title_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/wallet_provider.dart';
import 'package:mug/presentation/state/wallet_state.dart';
import 'package:mug/presentation/widget/widget.dart';
import 'package:mug/routes/routes_name.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WalletViewArg {
  final String address;
  final bool hasBalance;
  WalletViewArg(this.address, this.hasBalance);
}

class WalletView extends ConsumerStatefulWidget {
  final WalletViewArg arg;
  const WalletView(this.arg, {super.key});

  @override
  ConsumerState<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends ConsumerState<WalletView> {
  bool isAccountDefault = false;

  @override
  void initState() {
    super.initState();
    // Trigger wallet information loading
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(walletProvider.notifier).getWalletInformation(widget.arg.address, widget.arg.hasBalance);
      isAccountDefault = await ref.read(walletProvider.notifier).isAccountDefault(widget.arg.address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = ref.watch(settingProvider).darkTheme;
    final walletName = ref.watch(walletNameProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Wallet Details'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(walletProvider.notifier).getWalletInformation(widget.arg.address, widget.arg.hasBalance);
          },
          child: Consumer(
            builder: (context, ref, child) {
              return switch (ref.watch(walletProvider)) {
                WalletLoading() => const CircularProgressIndicator(),
                WalletSuccess(addressEntity: final addressEntity) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max, // Ensures the Column takes up the full available height
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: AddressIcon(addressEntity.address),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          walletName,
                          style: TextStyle(fontSize: Constants.fontSizeExtraLarge),
                        ),
                      ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Text(
                                    shortenString(addressEntity.address, Constants.shortedAddressLength),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: Constants.fontSize),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: addressEntity.address)).then((result) {
                                          if (context.mounted) {
                                            informationSnackBarMessage(context, "Wallet address copied!");
                                          }
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
                                leading: Text(
                                  "Balance",
                                  style: TextStyle(fontSize: Constants.fontSize),
                                ),
                                title: Text(
                                  "${formatNumber4(addressEntity.finalBalance + addressEntity.finalRolls * 100.00)} MAS",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: Constants.fontSize),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Constants.verticalSpacing),
                      // Tabs for Assets and Transactions
                      Expanded(
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              TabBar(
                                tabs: const [
                                  Tab(text: 'TOKENS'),
                                  Tab(text: 'TRANSACTIONS'),
                                  Tab(text: 'SETTING'),
                                ],
                                labelColor: Colors.blue,
                                unselectedLabelColor: Colors.grey,
                                labelStyle: TextStyle(fontSize: Constants.fontSizeExtraSmall),
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
                                                style: TextStyle(fontSize: Constants.fontSize),
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
                                            buildHeaderItem('Hash', 100),
                                            buildHeaderItem('Age', 110),
                                            buildHeaderItem('Status', 70),
                                            buildHeaderItem('Type', 100),
                                            buildHeaderItem('From', 110),
                                            buildHeaderItem('To', 110),
                                            buildHeaderItem('Amount', 120),
                                            buildHeaderItem('Fee', 80),
                                          ],
                                          leftSideItemBuilder: (context, index) {
                                            final history = addressEntity.transactionHistory?.combinedHistory?[index];
                                            return buildLeftSideItem(context, shortenString(history!.hash!, 10), index);
                                          },
                                          rightSideItemBuilder: (context, index) {
                                            final history = addressEntity.transactionHistory?.combinedHistory?[index];
                                            return buildRightSideItem(ref, history!, index);
                                          },
                                          itemCount: addressEntity.transactionHistory!.combinedHistory!.length,
                                        ),
                                      ),
                                    if (addressEntity.transactionHistory == null)
                                      const Text("No transaction history found"),

                                    Column(
                                      children: [
                                        SizedBox(height: Constants.verticalSpacing),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Wallet Name: $walletName",
                                                style: TextStyle(fontSize: Constants.fontSize),
                                              ),
                                              OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final newWalletName = await walletRenameBottomSheet(
                                                        context, addressEntity.address, isDarkTheme);
                                                    if (newWalletName!.isNotEmpty) {
                                                      ref
                                                          .read(walletNameProvider.notifier)
                                                          .updateWalletName(newWalletName);
                                                    }
                                                  },
                                                  label: const Text("Edit"),
                                                  icon: const Icon(Icons.edit)),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 0.5, color: Colors.brown[500]),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Private Key: ***",
                                                style: TextStyle(fontSize: Constants.fontSize),
                                              ),
                                              OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final wallet = await ref
                                                        .read(walletProvider.notifier)
                                                        .getWalletKey(addressEntity.address);

                                                    if (context.mounted) {
                                                      await privateKeyBottomSheet(context, wallet!, isDarkTheme);
                                                    }
                                                  },
                                                  label: const Text("Show"),
                                                  icon: const Icon(Icons.lock_open)),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 0.5, color: Colors.brown[500]),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              isAccountDefault
                                                  ? Text(
                                                      "Default Account: Yes",
                                                      style: TextStyle(fontSize: Constants.fontSize),
                                                    )
                                                  : Text(
                                                      "Default Account: No",
                                                      style: TextStyle(fontSize: Constants.fontSize),
                                                    ),
                                              if (!isAccountDefault)
                                                OutlinedButton.icon(
                                                    onPressed: () async {
                                                      final response = await defaultAccountBottomSheet(
                                                          context, addressEntity.address);
                                                      if (response!) {
                                                        ref
                                                            .read(walletProvider.notifier)
                                                            .setDefaultAccount(addressEntity.address);
                                                        if (context.mounted) {
                                                          informationSnackBarMessage(
                                                              context, "The wallet is set as a default wallet");
                                                        }
                                                        setState(() {
                                                          isAccountDefault = true;
                                                        });
                                                      }
                                                    },
                                                    label: const Text("Set"),
                                                    icon: const Icon(Icons.edit)),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 0.5, color: Colors.brown[500]),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0, bottom: 16),
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  if (addressEntity.finalBalance < 2 * ref.read(settingProvider).feeAmount) {
                                    informationSnackBarMessage(
                                        context, "Wallet balance is less than the required fee amount");
                                    return;
                                  }
                                  ref.read(screenTitleProvider.notifier).updateTitle("Transfer Fund");
                                  await Navigator.pushNamed(
                                    context,
                                    WalletRoutes.transfer,
                                    arguments: addressEntity,
                                  );
                                },
                                icon: const Icon(Icons.arrow_outward),
                                label: const Text('Send'),
                                iconAlignment: IconAlignment.start,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 32.0, bottom: 16),
                              child: FilledButton.tonalIcon(
                                onPressed: () {
                                  receiveBottomSheet(context, isDarkTheme, widget.arg.address);
                                },
                                icon: Transform.rotate(
                                  angle: 3.14,
                                  child: const Icon(Icons.arrow_outward),
                                ),
                                label: const Text('Receive'),
                                iconAlignment: IconAlignment.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                WalletFailure(message: final message) => Text(message),
              };
            },
          ),
        ),
      ),
    );
  }

  Future<String?> receiveBottomSheet(BuildContext context, bool isDarkTheme, String address) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 340,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
                children: <Widget>[
                  const Text(
                    'Wallet address',
                    style: TextStyle(fontSize: 20),
                  ),
                  QrImageView(
                    data: address,
                    version: QrVersions.auto,
                    eyeStyle: QrEyeStyle(
                        color: (isDarkTheme == true) ? Colors.white : Colors.black, eyeShape: QrEyeShape.circle),
                    dataModuleStyle: QrDataModuleStyle(
                      color: (isDarkTheme == true) ? Colors.white : Colors.black,
                    ),
                    size: 180.0,
                  ),
                  SizedBox(height: Constants.verticalSpacing),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      shortenString(address, Constants.shortedAddressLength),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: address)).then((result) {
                            if (context.mounted) {
                              informationSnackBarMessage(context, "Wallet address copied!");
                            }
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.copy)),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> walletRenameBottomSheet(BuildContext context, String address, bool isDarkTheme) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RenameWalletBottomSheet(address: address);
      },
    );
  }

  Future<bool?> privateKeyBottomSheet(BuildContext context, String privateKey, bool isDarkTheme) async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return PrivateKeyBottomSheet(privateKey, isDarkTheme);
      },
    );
  }

  Future<bool?> defaultAccountBottomSheet(BuildContext context, String address) async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return DefaultAccountBottomSheet(address);
      },
    );
  }
}
