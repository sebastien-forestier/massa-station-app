// Flutter imports:
import 'package:dusa/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/swap_provider.dart';
import 'package:mug/presentation/state/swap_state.dart';
import 'package:mug/presentation/widget/button_widget.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/snack_message.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';

class DexView extends ConsumerStatefulWidget {
  const DexView({super.key});

  @override
  ConsumerState<DexView> createState() => _DexViewState();
}

class _DexViewState extends ConsumerState<DexView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      ref.read(swapProvider.notifier).initialLoad(TokenName.WMAS, TokenName.USDC);
    });
  }

  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final swapState = ref.watch(swapProvider);
    final notifier = ref.read(swapProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Swap Tokens'),
      ),
      body: CommonPadding(
        child: RefreshIndicator(
          onRefresh: () {
            return ref.read(swapProvider.notifier).initialLoad(TokenName.WMAS, TokenName.USDC);
          },
          child: Consumer(
            builder: (context, ref, child) {
              var isDarkTheme = ref.watch(settingProvider).darkTheme;
              return switch (swapState.status) {
                SwapStatus.loading => Container(
                    color: Colors.black.withOpacity(0.0), // Semi-transparent overlay
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                SwapStatus.success => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[700]!, // Border color
                                width: 1.5, // Border width
                              ),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Row(
                              children: [
                                // TextFormField
                                Expanded(
                                  child: TextFormField(
                                    enabled: true,
                                    controller: _fromAmountController,
                                    onChanged: (value) {
                                      final value1 = double.parse(_fromAmountController.text.replaceAll(',', ''));
                                      _toAmountController.text = notifier.computeExchangeResult(value1).toString();
                                    },
                                    //keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '0.0000',
                                      border: InputBorder.none, // Removes internal border for seamless look
                                    ),
                                    style: const TextStyle(color: Colors.white, fontSize: 26),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?')),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10), // Add some spacing between dropdown and text box

                                // DropdownButton
                                Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: swapState.selectedDropdown1,
                                      items: _getDropdownItems(swapState.allItems),
                                      onChanged: (String? newValue) {
                                        notifier.selectDropdown1(newValue);
                                      },
                                      underline: const SizedBox(), // Removes the underline
                                      style: const TextStyle(color: Colors.white, fontSize: 16), // Text styling
                                      dropdownColor:
                                          Colors.grey[900], // Optional: Set dropdown background color for dark theme
                                    ),
                                    Text(
                                      "Balance: ${formatNumber4(swapState.balance1!)}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: FloatingActionButton(
                            onPressed: () {
                              notifier.flipTokens();
                              _fromAmountController.clear();
                              _toAmountController.clear();
                            },
                            backgroundColor: isDarkTheme ? ThemeData.dark().focusColor : ThemeData.light().focusColor,
                            elevation: 2.0,
                            child: const Icon(Icons.swap_vert, size: 28, color: Colors.white),
                          ),
                        ),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[700]!, // Border color
                                width: 1.5, // Border width
                              ),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Row(
                              children: [
                                // TextFormField
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    controller: _toAmountController,
                                    //onChanged: (value) {},
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: '0.0000',
                                      border: InputBorder.none, // Removes internal border for seamless look
                                    ),
                                    style: const TextStyle(color: Colors.white, fontSize: 26),
                                    inputFormatters: [
                                      TextInputFormatter.withFunction(
                                          (TextEditingValue oldValue, TextEditingValue newValue) {
                                        var formatter = NumberFormat('###,###.####', 'en_US');
                                        var value = formatter.tryParse(newValue.text) ?? 0;

                                        // If a decimal point was just added to the end of the value, keep it.
                                        if (newValue.text.endsWith('.') && '.'.allMatches(newValue.text).length == 1) {
                                          return newValue;
                                        }
                                        // Otherwise, format the value correctly.
                                        return TextEditingValue(
                                          text: formatter.format(value),
                                        );
                                      })
                                    ], // Text styling for dark theme
                                  ),
                                ),
                                const SizedBox(width: 10), // Add some spacing between dropdown and text box

                                // DropdownButton
                                Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: swapState.selectedDropdown2,
                                      items: _getDropdownItems(swapState.allItems),
                                      onChanged: (String? newValue) {
                                        notifier.selectDropdown2(newValue);
                                      },
                                      underline: const SizedBox(), // Removes the underline
                                      style: const TextStyle(color: Colors.white, fontSize: 16), // Text styling
                                      dropdownColor:
                                          Colors.grey[900], // Optional: Set dropdown background color for dark theme
                                    ),
                                    Text(
                                      "Balance: ${formatNumber4(swapState.balance2!)}",
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("1 MAS = ${swapState.exchangeRate} ${notifier.getOtherTokenName()}"),
                        ButtonWidget(
                          isDarkTheme: isDarkTheme,
                          text: "Swap",
                          onClicked: () {
                            final value1 = double.parse(_fromAmountController.text.replaceAll(',', ''));
                            final value2 = double.parse(_toAmountController.text.replaceAll(',', ''));
                            notifier.swap(value1, value2);
                            if (swapState.showNotification!) {
                              showSnackBarMessage(context, swapState.notificationMessage);
                            }
                            //swapState.notificationMessage!
                          },
                        ),
                        const SizedBox(height: 10),
                        if (swapState.showNotification!)
                          Card(
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              Text(
                                "Swap operation id: ${shortenString(swapState.notificationMessage!, 16)}",
                                textAlign: TextAlign.left,
                              ),
                              IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: swapState.notificationMessage!))
                                        .then((result) {
                                      //if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Copied operation ID: ${swapState.notificationMessage!}'),
                                      ));
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                  )),
                              IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                  onPressed: () {
                                    notifier.resetNotification();
                                  }),
                            ]),
                          ),

                        //   Card(
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         ListTile(
                        //           title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        //             Text(
                        //               "Swaping compted with operation id: ${swapState.notificationMessage!}",
                        //               textAlign: TextAlign.left,
                        //             ),
                        //             IconButton(
                        //                 onPressed: () {
                        //                   Clipboard.setData(ClipboardData(text: swapState.notificationMessage!))
                        //                       .then((result) {
                        //                     //if (!mounted) return;
                        //                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //                       content: Text('Address copied'),
                        //                     ));
                        //                   });
                        //                 },
                        //                 icon: const Icon(Icons.copy)),
                        //           ]),
                        //           trailing: ButtonWidget(
                        //               isDarkTheme: isDarkTheme,
                        //               text: "Dismis",
                        //               onClicked: () => notifier.resetNotification),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                SwapStatus.error => const Text("Something went wrong!"),
              };
            },
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems(Map<String, DropdownItem> items) {
    return items.entries.map((entry) {
      return DropdownMenuItem<String>(
        value: entry.key,
        child: Row(
          children: [
            SvgPicture.asset(entry.value.iconPath, semanticsLabel: entry.key, height: 24.0, width: 24.0),
            const SizedBox(width: 10),
            Text(entry.key),
          ],
        ),
      );
    }).toList();
  }
}
