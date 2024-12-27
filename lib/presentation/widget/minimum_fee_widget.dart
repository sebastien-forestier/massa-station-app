import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mug/presentation/provider/setting_provider.dart';

class EditableFeeWidget extends ConsumerStatefulWidget {
  const EditableFeeWidget({super.key});

  @override
  ConsumerState<EditableFeeWidget> createState() => _EditableFeeWidgetState();
}

class _EditableFeeWidgetState extends ConsumerState<EditableFeeWidget> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final setting = ref.watch(settingProvider);
    _controller = TextEditingController(text: setting.feeAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    final setting = ref.watch(settingProvider);

    setState(() {
      if (_isEditing) {
        // Save the value (add validation logic here if needed)
        final enteredValue = double.tryParse(_controller.text);
        if (enteredValue != null) {
          ref.read(settingProvider.notifier).changeFee(feeAmount: enteredValue);
        }
      } else {
        // Update the TextField with the latest provider value
        _controller.text = setting.feeAmount.toStringAsFixed(2);
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider value
    final setting = ref.watch(settingProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Form Field
        Expanded(
          child: TextFormField(
            controller: _controller,
            enabled: _isEditing,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Minimum Fee',
              hintText: setting.feeAmount.toStringAsFixed(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Edit/Save Icon
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          color: _isEditing ? Colors.green : Colors.blue,
          onPressed: _toggleEditMode,
        ),
      ],
    );
  }
}
