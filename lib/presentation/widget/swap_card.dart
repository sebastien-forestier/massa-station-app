import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:mug/domain/entity/entity.dart';
import 'package:mug/presentation/provider/dex_swap_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/utils/number_helpers.dart';

class SwapCard extends ConsumerWidget {
  SwapCard({super.key});

  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAmountController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the dropdown state
    final dropdownState = ref.watch(dropdownProvider);

    var isDarkTheme = ref.watch(settingProvider).darkTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                        final value2 = value1 * dropdownState.exchangeRate!;
                        ref.read(dropdownProvider.notifier).updateValues(value1, value2);
                        _toAmountController.text = (value2).toString();
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0.0000',
                        border: InputBorder.none, // Removes internal border for seamless look
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 26),
                      inputFormatters: [
                        TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) {
                          var formatter = NumberFormat('###,###.####', 'en_US');
                          var value = formatter.tryParse(newValue.text) ?? 0;
                          if (newValue.text.endsWith('.') && '.'.allMatches(newValue.text).length == 1) {
                            return newValue;
                          }
                          return TextEditingValue(
                            text: formatter.format(value),
                          );
                        })
                      ],
                    ),
                  ),
                  const SizedBox(width: 10), // Add some spacing between dropdown and text box

                  // DropdownButton
                  Column(
                    children: [
                      DropdownButton<String>(
                        value: dropdownState.selectedDropdown1,
                        items: _getDropdownItems(dropdownState.allItems),
                        onChanged: (String? newValue) {
                          ref.read(dropdownProvider.notifier).selectDropdown1(newValue);
                        },
                        underline: const SizedBox(), // Removes the underline
                        style: const TextStyle(color: Colors.white, fontSize: 16), // Text styling
                        dropdownColor: Colors.grey[900], // Optional: Set dropdown background color for dark theme
                      ),
                      Text(
                        "Balance: ${formatNumber4(dropdownState.balance1!)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                ref.read(dropdownProvider.notifier).flipTokens();
                _fromAmountController.text = dropdownState.value1.toString();
                _toAmountController.text = dropdownState.value2.toString();
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
                        TextInputFormatter.withFunction((TextEditingValue oldValue, TextEditingValue newValue) {
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
                        value: dropdownState.selectedDropdown2,
                        items: _getDropdownItems(dropdownState.allItems),
                        onChanged: (String? newValue) {
                          ref.read(dropdownProvider.notifier).selectDropdown2(newValue);
                        },
                        underline: const SizedBox(), // Removes the underline
                        style: const TextStyle(color: Colors.white, fontSize: 16), // Text styling
                        dropdownColor: Colors.grey[900], // Optional: Set dropdown background color for dark theme
                      ),
                      Text(
                        "Balance: ${formatNumber4(dropdownState.balance2!)}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          // Dropdown 2 (same list but excludes Dropdown 1's selected item)
        ],
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
