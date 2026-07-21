import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_settings/view_model/settings_view_model.dart';
import 'package:gastromic/app/views/view_settings/widgets/settings_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class SettingsView extends StatelessWidget with SettingsWidgets {

  SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(

      create: (_) => SettingsViewModel()..add(SettingsInitialEvent()),
      child: BlocBuilder<SettingsViewModel, SettingsState>(
        builder: (context, state) {
          final viewModel = context.read<SettingsViewModel>();

          if (state.status == ViewStatus.loading && state.profile == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.profile == null) {
            return Scaffold(
              body: Center(child: Text(state.errorMessage ?? 'Bir hata oluştu')),
            );
          }

          final profile = state.profile!;
          return Scaffold(
            backgroundColor: context.cBackground,
            appBar: AppBar(
              backgroundColor: context.cBackground,
              title: Text('Profilim', style: context.titleLarge),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: context.paddingNormal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    profileCard(context, profile: profile, onEditTap: () {}),
                    context.sizedHeightBoxMedium,
                    Text('HESAP AYARLARI', style: context.bodyMedium),
                    context.sizedHeightBoxNormal,
                    settingsRow(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Şifre Değiştir',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    settingsRow(
                      context,
                      icon: Icons.notifications_none,
                      title: 'Bildirimler',
                      trailing: Switch(
                        value: profile.notificationsEnabled,
                        activeColor: context.cPrimary,
                        onChanged: (value) => viewModel.add(
                          SettingsNotificationToggledEvent(value),
                        ),
                      ),
                    ),
                    settingsRow(
                      context,
                      icon: Icons.brightness_6_outlined,
                      title: 'Tema',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    settingsRow(
                      context,
                      icon: Icons.language,
                      title: 'Dil',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    context.sizedHeightBoxMedium,
                    OutlinedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.router.replaceAll([LoginViewRoute()]);
                        }
                      },
                      child: const Text('Çıkış Yap'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
