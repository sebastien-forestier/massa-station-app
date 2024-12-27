// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart' as ht;
import 'package:massa/massa.dart';
import 'package:mug/data/model/transaction_history.dart';

// Project imports:
import 'package:mug/presentation/provider/address_provider.dart';
import 'package:mug/presentation/provider/screen_title_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/wallet_provider.dart';
import 'package:mug/presentation/state/address_state.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/default_account_widget.dart';
import 'package:mug/presentation/widget/private_key_bottomsheet_widget.dart';
import 'package:mug/routes/routes_name.dart';
import 'package:mug/service/massa_icon/svg.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AccountView extends ConsumerStatefulWidget {
  final String address;
  const AccountView(this.address, {super.key});

  @override
  ConsumerState<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  bool isAccountDefault = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      ref.read(addressProvider.notifier).getAddress(widget.address, true);
      isAccountDefault = await ref.read(walletProvider.notifier).isAccountDefault(widget.address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAccount = ref.read(walletProvider.notifier).isAccountExisting(widget.address);
    final isDarkTheme = ref.watch(settingProvider).darkTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: isAccount.$1 ? const Text('Account Details') : const Text('Address Details'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(addressProvider.notifier).getAddress(widget.address, true);
          },
          child: Consumer(
            builder: (context, ref, child) {
              return switch (ref.watch(addressProvider)) {
                AddressInitial() => const Text('Account information is loading....'),
                AddressLoading() => const CircularProgressIndicator(),
                AddressSuccess(addressEntity: final addressEntity) => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max, // Ensures the Column takes up the full available height
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: generateRadial(addressEntity.address),
                          // child: AvatarGenerator(
                          //   seed: addressEntity.address,
                          //   tilePadding: 2.0,
                          //   colors: const [Colors.white70, Colors.black, Colors.blue],
                          // ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          addressEntity.address.substring(addressEntity.address.length - 4),
                          style: const TextStyle(fontSize: 40),
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
                                    shortenString(addressEntity.address, 30),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 18),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: const Text(
                                  "Balance",
                                  style: TextStyle(fontSize: 18),
                                ),
                                title: Text(
                                  "${formatNumber4(addressEntity.finalBalance + addressEntity.finalRolls * 100.00)} MAS",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                //subtitle: const Text("MAS", textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
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
                                  Tab(text: 'SETTING'),
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
                                          // rowSeparatorWidget: const Divider(
                                          //   color: Colors.black54,
                                          //   height: 0.1,
                                          //   thickness: 0.0,
                                          // ),
                                        ),
                                      ),
                                    if (addressEntity.transactionHistory == null)
                                      const Text("No transaction history found"),

                                    Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Account Name: ${addressEntity.address.substring(addressEntity.address.length - 4)}",
                                                style: const TextStyle(fontSize: 18),
                                              ),
                                              OutlinedButton.icon(
                                                  onPressed: () {}, label: const Text("Edit"), icon: Icon(Icons.edit)),
                                            ],
                                          ),
                                        ),
                                        Divider(thickness: 0.5, color: Colors.brown[500]),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Private Key: ***",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              OutlinedButton.icon(
                                                  onPressed: () async {
                                                    final wallet = await ref
                                                        .read(walletProvider.notifier)
                                                        .getWallet(addressEntity.address);
                                                    await privateKeyBottomSheet(context, wallet!, isDarkTheme);
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
                                                  ? const Text(
                                                      "Default Account: Yes",
                                                      style: TextStyle(fontSize: 18),
                                                    )
                                                  : const Text(
                                                      "Default Account: No",
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                              // FutureBuilder<bool>(
                                              //   future: ref
                                              //       .watch(walletProvider.notifier)
                                              //       .isAccountDefault(addressEntity.address),
                                              //   builder: (context, snapshot) {
                                              //     if (snapshot.connectionState == ConnectionState.waiting) {
                                              //       return const CircularProgressIndicator(); // Show a loading spinner
                                              //     } else if (snapshot.hasData) {
                                              //       if (snapshot.data!) {
                                              //         return const Text(
                                              //           "Default Account: Yes",
                                              //           style: TextStyle(fontSize: 18),
                                              //         );
                                              //       }
                                              //       return const Text(
                                              //         "Default Account: No",
                                              //         style: TextStyle(fontSize: 18),
                                              //       );
                                              //     } else {
                                              //       return const Text(
                                              //         "Default Account: No",
                                              //         style: TextStyle(fontSize: 18),
                                              //       );
                                              //     }
                                              //   },
                                              // ),

                                              if (!isAccountDefault)
                                                OutlinedButton.icon(
                                                    onPressed: () async {
                                                      final response = await defaultAccountBottomSheet(
                                                          context, addressEntity.address);

                                                      if (response!) {
                                                        ref
                                                            .read(walletProvider.notifier)
                                                            .setDefaultAccount(addressEntity.address);
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                          content: Text('The account is set as a default!'),
                                                        ));

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
                              padding: const EdgeInsets.only(left: 32.0),
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
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
                              padding: const EdgeInsets.only(right: 32.0),
                              child: FilledButton.tonalIcon(
                                onPressed: () {
                                  receiveBottomSheet(context, isDarkTheme, widget.address);
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
        _buildRightItem(computeAge(int.parse(history.blockTime!)), 110, index),
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

  Future<String?> receiveBottomSheet(BuildContext context, bool isDarkTheme, String address) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Allow the BottomSheet to resize
      builder: (BuildContext context) {
        return SizedBox(
          height: 340,
          child: SingleChildScrollView(
            // Allow scrolling if the content exceeds height
            child: Padding(
              // padding: const EdgeInsets.all(16.0),
              padding: EdgeInsets.only(top: 20, right: 20, left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
                children: <Widget>[
                  const Text(
                    'Account address',
                    style: TextStyle(fontSize: 20),
                  ),
                  QrImageView(
                    data: address,
                    version: QrVersions.auto,
                    //backgroundColor:
                    eyeStyle: QrEyeStyle(
                        color: (isDarkTheme == true) ? Colors.white : Colors.black, eyeShape: QrEyeShape.circle),
                    dataModuleStyle: QrDataModuleStyle(
                      color: (isDarkTheme == true) ? Colors.white : Colors.black,
                    ),
                    size: 180.0,
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      shortenString(address, 24),
                      textAlign: TextAlign.left,
                    ),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: address)).then((result) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Address copied'),
                            ));
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

  // Future<String?> privateKeyBottomSheet(BuildContext context, bool isDarkTheme, String address) async {
  //   return showModalBottomSheet<String>(
  //     context: context,
  //     isScrollControlled: true, // Allow the BottomSheet to resize
  //     builder: (BuildContext context) {
  //       return Consumer(
  //         builder: (context, ref, child) {
  //           return Container(
  //             padding: const EdgeInsets.all(16.0),
  //             height: 200,
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 SizedBox(
  //                   width: 50,
  //                   height: 50,
  //                   child: generateRadial(address),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     ref.read(walletProvider.notifier).setDefaultAccount(address);
  //                   },
  //                   child: const Text("Make Default"),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

//   Future<String?> defaultAccountBottomSheet(BuildContext context, bool isDarkTheme, String address) async {
//     return showModalBottomSheet<String>(
//       context: context,
//       isScrollControlled: true, // Allow the BottomSheet to resize
//       builder: (BuildContext context) {
//         return Consumer(
//           builder: (context, ref, child) {
//             return SizedBox(
//               height: 340,
//               child: SingleChildScrollView(
//                 // Allow scrolling if the content exceeds height
//                 child: Padding(
//                   // padding: const EdgeInsets.all(16.0),
//                   padding:
//                       EdgeInsets.only(top: 20, right: 20, left: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start, // Align items to the top
//                     children: <Widget>[
//                       const Text(
//                         'Are you shure',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       QrImageView(
//                         data: address,
//                         version: QrVersions.auto,
//                         //backgroundColor:
//                         eyeStyle: QrEyeStyle(
//                             color: (isDarkTheme == true) ? Colors.white : Colors.black, eyeShape: QrEyeShape.circle),
//                         dataModuleStyle: QrDataModuleStyle(
//                           color: (isDarkTheme == true) ? Colors.white : Colors.black,
//                         ),
//                         size: 180.0,
//                       ),
//                       const SizedBox(height: 10),
//                       Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                         Text(
//                           shortenString(address, 24),
//                           textAlign: TextAlign.left,
//                         ),
//                         IconButton(
//                             onPressed: () {
//                               Clipboard.setData(ClipboardData(text: address)).then((result) {
//                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                                   content: Text('Address copied'),
//                                 ));
//                               });
//                               Navigator.pop(context);
//                             },
//                             icon: const Icon(Icons.copy)),
//                       ]),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//             // return Container(
//             //   padding: const EdgeInsets.all(16.0),
//             //   height: 200,
//             //   child: Column(
//             //     mainAxisAlignment: MainAxisAlignment.center,
//             //     children: [
//             //       SizedBox(
//             //         width: 50,
//             //         height: 50,
//             //         child: generateRadial(address),
//             //       ),
//             //       const SizedBox(height: 20),
//             //       ElevatedButton(
//             //         onPressed: () {
//             //           ref.read(walletProvider.notifier).setDefaultAccount(address);
//             //         },
//             //         child: const Text("Make Default"),
//             //       ),
//             //     ],
//             //   ),
//             // );
//           },
//         );
//       },
//     );
//   }
// }

//TODO: move this function to the provider
  String computeAge(int timestampMillis) {
    // Convert input timestamp from milliseconds to DateTime
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);

    // Get the current time in UTC
    DateTime now = DateTime.now().toUtc();

    // Calculate the difference as a Duration
    Duration difference = now.difference(timestamp);

    if (difference.inSeconds < 86400) {
      // Less than a day, format as hh:mm:ss
      int hours = difference.inHours;
      int minutes = difference.inMinutes % 60;
      int seconds = difference.inSeconds % 60;
      return '${hours.toString().padLeft(2, '0')}h '
          '${minutes.toString().padLeft(2, '0')}m '
          '${seconds.toString().padLeft(2, '0')}s';
    } else if (difference.inDays < 30) {
      // Less than a month, format as d:hh:mm
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;
      return '${days}d ${hours.toString().padLeft(2, '0')}h '
          '${minutes.toString().padLeft(2, '0')}m';
    } else if (difference.inDays < 365) {
      // Less than a year, format as m:d:h
      int months = difference.inDays ~/ 30; // Approximate months
      int days = difference.inDays % 30;
      int hours = difference.inHours % 24;
      return '${months}m ${days}d ${hours}h';
    } else {
      // Greater than or equal to a year, show years:months:days
      int years = difference.inDays ~/ 365;
      int months = (difference.inDays % 365) ~/ 30; // Approximate months
      int days = (difference.inDays % 365) % 30;
      return '${years}y ${months}m ${days}d';
    }
  }

// Function to display the Yes-No confirmation bottom sheet
  Future<bool?> privateKeyBottomSheet(BuildContext context, String privateKey, bool isDarkTheme) async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return PrivateKeyBottomSheet(privateKey, isDarkTheme);
      },
    );
  }

// Function to display the Yes-No confirmation bottom sheet
  Future<bool?> defaultAccountBottomSheet(BuildContext context, String address) async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return DefaultAccountBottomSheet(address);
      },
    );
  }

// // Bottom sheet widget
// class YesNoBottomSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "Are you sure?",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 16.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 onPressed: () {
//                   Navigator.of(context).pop(true); // Return true for YES
//                 },
//                 child: Text("Yes"),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 onPressed: () {
//                   Navigator.of(context).pop(false); // Return false for NO
//                 },
//                 child: Text("No"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
}
