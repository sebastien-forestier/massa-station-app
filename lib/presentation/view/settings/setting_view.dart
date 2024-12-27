// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:mug/presentation/widget/slipage_widget.dart';
import 'package:mug/presentation/widget/widget.dart';
import 'package:mug/presentation/widget/common_padding.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text("Settings")),
      body: CommonPadding(
        child: ListView(
          children: <Widget>[
            // const NetworkListTileWidget(),
            // const Divider(height: 1),
            // const ThemeListTileWidget(),
            // const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.gas_meter_outlined),
              title: const Text("Minimum Gass: 0.045 MAS"),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text("Transaction fee: 0.01 MAS"),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ),
            //const Divider(height: 1),
            // ListTile(
            //   leading: Icon(Icons.payment_outlined),
            //   title: Text("Fee:"),
            //   trailing: EditableFeeWidget(),
            //   //trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            // ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.payment_outlined),
              title: Text("Slipage:"),
              trailing: SlippageWidget(),
              //trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ),
            const Divider(height: 1),

            // ListTile(
            //   leading: const Icon(Icons.payment_outlined),
            //   title: const Text("Select Default Account: 0.00001 MASSA"),
            //   trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            // ),
            const InfoListTileWidget(),
          ],
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange}) : assert(decimalRange > 0);
  final int decimalRange;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;
    String value = newValue.text;
    if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";
      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }
    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
