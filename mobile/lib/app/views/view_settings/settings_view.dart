import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cBackground,
      body: SafeArea(
        child: Column(
          children: [
            Center(child: Text('Ayarlar', style: context.titleLarge)),
            context.sizedHeightBoxMedium,
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  context.router.replaceAll([LoginViewRoute()]);
                }
              },
              child: const Text('Çıkış Yap (test)'),
            ),
          ],
        ),
      ),
    );
  }
}
