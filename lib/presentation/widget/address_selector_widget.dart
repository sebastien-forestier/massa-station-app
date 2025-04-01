import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/wallet_list_provider.dart';
import 'package:mug/utils/string_helpers.dart';

class AddressSelectorWidget extends ConsumerWidget {
  final String currentAddress;
  final TextEditingController addressController;
  //final GlobalKey<FormState> formKey;

  const AddressSelectorWidget({
    required this.currentAddress,
    required this.addressController,
    //required this.formKey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the walletProvider
    final walletAsyncValue = ref.watch(walletListProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // TextFormField
              Expanded(
                child: TextFormField(
                  enabled: true,
                  maxLines: 3,
                  controller: addressController,
                  onChanged: (value) {},
                  decoration: const InputDecoration(
                    hintText: 'Please enter the recipent address here or select the address from the list.',
                    border: InputBorder.none, // Removes internal border for seamless look
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Address from List",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          walletAsyncValue.when(
            data: (walletData) {
              if (walletData == null || walletData.wallets.isEmpty) {
                return const Text("No available addresses to select.");
              }
              // Filter out the current address
              final wallets = walletData.wallets.where((wallet) => wallet.address != currentAddress).toList();

              return DropdownButtonFormField<String>(
                items: wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet.address,
                        child: Text(shortenString(wallet.address, 26)),
                      ),
                    )
                    .toList(),
                onChanged: (selectedAddress) {
                  if (selectedAddress != null) {
                    addressController.text = selectedAddress; // Populate the text field
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                hint: const Text('Select an address'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text('Error loading addresses: $error'),
          ),
        ],
      ),
    );
  }
}
