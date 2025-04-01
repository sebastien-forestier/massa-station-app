// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutState();
}

class _AboutState extends State<AboutWidget> {
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationIcon: SvgPicture.asset(
        'assets/icons/mu.svg',
        height: 40,
        width: 40,
      ),
      applicationName: 'MUG',
      applicationVersion: 'Version 1.2.0',
      applicationLegalese: '\u{a9} 2025 Massa',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About'),
      onTap: () {
        _showAboutDialog();
      },
    );
  }
}
