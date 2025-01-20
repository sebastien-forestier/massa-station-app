// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mug/constants/asset_names.dart';
import 'package:mug/domain/entity/address_entity.dart';

// Project imports:
import 'package:mug/presentation/provider/address_provider.dart';
import 'package:mug/presentation/provider/screen_title_provider.dart';
import 'package:mug/presentation/provider/setting_provider.dart';
import 'package:mug/presentation/provider/transfer_provider.dart';
import 'package:mug/presentation/state/transfer_state.dart';
import 'package:mug/presentation/widget/address_selector_widget.dart';
import 'package:mug/presentation/widget/common_padding.dart';
import 'package:mug/presentation/widget/custom_label_widget.dart';
import 'package:mug/presentation/widget/information_card_widget.dart';
import 'package:mug/presentation/widget/information_snack_message.dart';
import 'package:mug/presentation/widget/success_information_widget.dart';
import 'package:mug/utils/number_helpers.dart';
import 'package:mug/utils/string_helpers.dart';

class TransferView extends ConsumerWidget {
  final AddressEntity addressEntity;
  const TransferView(this.addressEntity, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    final transactionFee = ref.watch(settingProvider).feeAmount;

    final screenTitle = ref.watch(screenTitleProvider);
    return Scaffold(
      appBar: AppBar(centerTitle: false, title: Text(screenTitle)),
      body: SingleChildScrollView(
        child: CommonPadding(
          child: RefreshIndicator(
            onRefresh: () {
              return ref.read(addressProvider.notifier).getAddress(addressEntity.address, false);
            },
            child: Consumer(
              builder: (context, ref, child) {
                // var isDarkTheme = ref.watch(settingProvider).darkTheme;
                return switch (ref.watch(transferProvider)) {
                  TransferInitial() => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Text(
                              "Available Balance",
                              style: TextStyle(fontSize: 18),
                            ),
                            title: Text(
                              "${formatNumber4(addressEntity.finalBalance)} MAS",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                            //subtitle: const Text("MAS", textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                            label: "Sending Address",
                            value: Text(addressEntity.address, style: const TextStyle(fontSize: 20))),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                          label: "Recipient Address",
                          value: AddressSelectorWidget(
                              currentAddress: addressEntity.address, addressController: addressController),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 46, 53, 56), // Border color
                                width: 1.5, // Border width
                              ),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Row(
                              children: [
                                // TextFormField
                                Expanded(
                                  child: Form(
                                    key: formKey,
                                    child: TextFormField(
                                      enabled: true,
                                      controller: amountController,
                                      onChanged: (value) {},
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a value';
                                        }
                                        try {
                                          final enteredValue = double.parse(value);
                                          if (enteredValue > addressEntity.finalBalance - transactionFee) {
                                            return 'Value should not exceed ${addressEntity.finalBalance - transactionFee}';
                                          }
                                        } catch (e) {
                                          return 'Please enter a valid decimal number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Add some spacing between dropdown and text box
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(AssetName.mas,
                                            semanticsLabel: "MAS", height: 40.0, width: 40.0),
                                        const SizedBox(width: 10),
                                        const Text("MAS", style: TextStyle(fontSize: 24))
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text("Fee: ${ref.watch(settingProvider).feeAmount} MAS"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const InformationCardWidget(
                            message: "Please confirm the amount and recepient address before transfering your fund"),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            if (!formKey.currentState!.validate() ||
                                addressController.text.isEmpty ||
                                addressController.text == addressEntity.address) {
                              informationSnackBarMessage(context, 'One of the entries is invalid. Try again!');
                              return;
                            }
                            final amount = double.parse(amountController.text);
                            final recipientAddress = addressController.text;
                            await ref
                                .read(transferProvider.notifier)
                                .transfer(addressEntity.address, recipientAddress, amount);
                          },
                          icon: const Icon(Icons.arrow_outward),
                          label: const Text('Send'),
                          iconAlignment: IconAlignment.start,
                        ),
                      ],
                    ),
                  TransferLoading() => const CircularProgressIndicator(),
                  TransferSuccess(transferEntity: final transfersEntity) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const SuccessInformationWidget(message: "Fund transfered successfully!"),
                        const SizedBox(height: 20),
                        CustomLabelWidget(
                            label: "Sending Address",
                            value: Text(transfersEntity.sendingAddress!, style: const TextStyle(fontSize: 20))),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                            label: "Receipient Address",
                            value: Text(transfersEntity.recipientAddress!, style: const TextStyle(fontSize: 20))),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                          label: "Amount Transfered",
                          value: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: Text(
                                transfersEntity.amount.toString(),
                                style: const TextStyle(fontSize: 26),
                              )),
                              const SizedBox(width: 10), // Add some spacing between dropdown and text box
                              Row(
                                children: [
                                  SvgPicture.asset(AssetName.mas, semanticsLabel: "MAS", height: 40.0, width: 40.0),
                                  const SizedBox(width: 10),
                                  const Text("MAS", style: TextStyle(fontSize: 24))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                          label: "Transaction Fee ",
                          value: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  child: Text(
                                transactionFee.toString(),
                                style: const TextStyle(fontSize: 26),
                              )),
                              const SizedBox(width: 10), // Add some spacing between dropdown and text box
                              Row(
                                children: [
                                  SvgPicture.asset(AssetName.mas, semanticsLabel: "MAS", height: 40.0, width: 40.0),
                                  const SizedBox(width: 10),
                                  const Text("MAS", style: TextStyle(fontSize: 24))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomLabelWidget(
                          label: "Operation ID",
                          value: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              shortenString(transfersEntity.operationID!, 26),
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: addressEntity.address)).then((result) {
                                    informationSnackBarMessage(context, 'Operation ID copied');
                                  });
                                },
                                icon: const Icon(Icons.copy)),
                          ]),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            ref.read(transferProvider.notifier).resetState();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          iconAlignment: IconAlignment.start,
                        ),
                      ],
                    ),
                  TransferFailure(message: final message) => Text(message),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
