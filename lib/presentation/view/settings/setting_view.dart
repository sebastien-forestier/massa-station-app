// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/setting_provider.dart';

// Project imports:
import 'package:mug/presentation/widget/slipage_widget.dart';
import 'package:mug/presentation/widget/information_snack_message.dart';
import 'package:mug/presentation/widget/widget.dart';
import 'package:mug/presentation/widget/common_padding.dart';

class SettingView extends ConsumerStatefulWidget {
  const SettingView({super.key});

  @override
  ConsumerState<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends ConsumerState<SettingView> {
  _SettingViewState();

  late TextEditingController _txFeeController;
  late TextEditingController _gasFeeController;
  bool _isTxFeeEditing = false;
  bool _isGasFeeEditing = false;

  @override
  void initState() {
    super.initState();
    final initialTransactionFee = ref.read(settingProvider).feeAmount;
    final initialGasFee = ref.read(settingProvider).gasAmount;
    _txFeeController = TextEditingController(text: initialTransactionFee.toStringAsFixed(4));
    _gasFeeController = TextEditingController(text: initialGasFee.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _txFeeController.dispose();
    _gasFeeController.dispose();
    super.dispose();
  }

  void _toggleTxFeeEditMode() {
    setState(() {
      if (_isTxFeeEditing) {
        // Save the value (add validation logic here if needed)

        final enteredValue = double.tryParse(_txFeeController.text);
        print("if fee amount: $enteredValue");

        if (enteredValue != null && enteredValue >= 0.01) {
          ref.read(settingProvider.notifier).changeTxFee(feeAmount: enteredValue);
          informationSnackBarMessage(context, "The transaction fee is set to ${enteredValue.toStringAsFixed(4)} MAS");
        }
      } else {
        // Update the TextField with the latest provider value
        final currentFee = ref.read(settingProvider).feeAmount;
        print("else fee amount: $currentFee");
        _txFeeController.text = currentFee.toStringAsFixed(4);
      }
      _isTxFeeEditing = !_isTxFeeEditing;
    });
  }

  void _toggleGasFeeEditMode() {
    setState(() {
      if (_isGasFeeEditing) {
        // Save the value (add validation logic here if needed)
        final enteredValue = double.tryParse(_gasFeeController.text);
        if (enteredValue != null && enteredValue >= 0.01) {
          ref.read(settingProvider.notifier).changeGasFee(gasFeeAmount: enteredValue);

          informationSnackBarMessage(context, 'The gas fee is set to ${enteredValue.toStringAsFixed(4)} MAS');
        }
      } else {
        final currentFee = ref.read(settingProvider).gasAmount;
        _gasFeeController.text = currentFee.toStringAsFixed(4);
      }
      _isGasFeeEditing = !_isGasFeeEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minimumTxFee = ref.watch(settingProvider).feeAmount;
    final minimumGasFee = ref.watch(settingProvider).gasAmount;
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: const Text("Settings")),
      body: CommonPadding(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.gas_meter_outlined),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Gas Fee:"),
                  const SizedBox(width: 10),
                  // Form Field
                  Expanded(
                    child: TextFormField(
                      controller: _gasFeeController,
                      enabled: _isGasFeeEditing,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: minimumGasFee.toStringAsFixed(4),
                      ),
                      autocorrect: true,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text("MAS"),
                ],
              ),
              trailing: IconButton(
                icon: Icon(_isGasFeeEditing ? Icons.save : Icons.edit),
                color: _isTxFeeEditing
                    ? const Color.fromARGB(255, 104, 191, 208)
                    : const Color.fromARGB(255, 246, 247, 247),
                onPressed: _toggleGasFeeEditMode,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transaction Fee:"),
                  const SizedBox(width: 10),
                  // Form Field
                  Expanded(
                    child: TextFormField(
                      controller: _txFeeController,
                      enabled: _isTxFeeEditing,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: minimumTxFee.toStringAsFixed(4),
                      ),
                      autocorrect: true,
                    ),
                  ),
                  // Edit/Save Icon
                  const SizedBox(width: 2),
                  const Text("MAS"),
                ],
              ),
              trailing: IconButton(
                icon: Icon(_isTxFeeEditing ? Icons.save : Icons.edit),
                color: _isTxFeeEditing
                    ? const Color.fromARGB(255, 104, 191, 208)
                    : const Color.fromARGB(255, 246, 247, 247),
                onPressed: _toggleTxFeeEditMode,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.double_arrow),
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Text("Slipage:"),
                const SizedBox(width: 16),
                SlippageWidget(),
              ]),
            ),
            const Divider(height: 1),
            const InfoListTileWidget(),
          ],
        ),
      ),
    );
  }
}
