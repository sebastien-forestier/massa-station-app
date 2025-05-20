import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/wallet_list_provider.dart';
import 'package:mug/utils/string_helpers.dart';

class AddressSelectorWidget extends ConsumerStatefulWidget {
  final String currentAddress;
  final TextEditingController addressController;

  const AddressSelectorWidget({
    required this.currentAddress,
    required this.addressController,
    super.key,
  });

  @override
  ConsumerState<AddressSelectorWidget> createState() => _AddressSelectorWidgetState();
}

class _AddressSelectorWidgetState extends ConsumerState<AddressSelectorWidget> {
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    widget.addressController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.addressController.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (_selectedAddress != null && widget.addressController.text != _selectedAddress) {
      setState(() {
        _selectedAddress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsyncValue = ref.watch(walletListProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: true,
                  maxLines: 3,
                  controller: widget.addressController,
                  onChanged: (value) {
                    // The listener will handle resetting the dropdown
                  },
                  decoration: const InputDecoration(
                    hintText: 'Please paste the recipent address here',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(thickness: 1, color: Colors.blue, height: 24),
          const Text(
            "OR Transer to your address",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          walletAsyncValue.when(
            data: (walletData) {
              if (walletData == null || walletData.wallets.isEmpty) {
                return const Text("No available addresses to select.");
              }
              final wallets = walletData.wallets.where((wallet) => wallet.address != widget.currentAddress).toList();

              return DropdownButtonFormField<String>(
                value: _selectedAddress,
                items: wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet.address,
                        child: Text(shortenString(wallet.address, 26)),
                      ),
                    )
                    .toList(),
                onChanged: (selectedAddress) {
                  setState(() {
                    _selectedAddress = selectedAddress;
                    if (selectedAddress != null) {
                      widget.addressController.text = selectedAddress;
                    }
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  hintText: 'Select the recipient address',
                ),
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
