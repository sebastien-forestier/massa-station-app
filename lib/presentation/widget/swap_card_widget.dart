import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mug/presentation/provider/dex_swap_provider.dart';
import 'package:mug/utils/number_helpers.dart';

class SwapCardWidget extends ConsumerWidget {
  final String label;
  final String currency;
  final Map<String, DropdownItem> coinItems;
  final TextEditingController amountController;
  final ValueChanged<String?> onCurrencyChanged;
  final double balance;
  final ValueChanged<String?> onChanged;
  final bool isEnabled;

  const SwapCardWidget({
    super.key,
    required this.label,
    required this.currency,
    required this.coinItems,
    required this.amountController,
    required this.onCurrencyChanged,
    required this.balance,
    required this.onChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropdownState = ref.watch(dropdownProvider);

    return Card(
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
                  enabled: isEnabled,
                  controller: amountController,
                  onChanged: onChanged,
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
              const SizedBox(width: 12), // Add some spacing between dropdown and text box

              // DropdownButton
              Column(
                children: [
                  DropdownButton<String>(
                    value: currency,
                    items: _getDropdownItems(),
                    onChanged: onCurrencyChanged,
                    underline: const SizedBox(), // Removes the underline
                    style: const TextStyle(color: Colors.white, fontSize: 16), // Text styling
                    dropdownColor: Colors.grey[900], // Optional: Set dropdown background color for dark theme
                  ),
                  Text(
                    "Balance: ${formatNumber4(balance)}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ));
  }

  List<DropdownMenuItem<String>> _getDropdownItems() {
    return coinItems.entries.map((entry) {
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
