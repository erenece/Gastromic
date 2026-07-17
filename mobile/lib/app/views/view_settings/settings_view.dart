import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBackground,
      body: SafeArea(
        child: Center(child: Text('Ayarlar', style: context.titleLarge)),
      ),
    );
  }
}
