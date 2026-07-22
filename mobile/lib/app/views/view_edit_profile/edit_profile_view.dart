import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_edit_profile/view_model/edit_profile_view_model.dart';
import 'package:gastromic/app/views/view_edit_profile/widgets/edit_profile_widgets.dart';
import 'package:gastromic/app/views/view_settings/repository/model/settings_profile_model.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/auth_text_field.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

@RoutePage()
class EditProfileView extends StatelessWidget with EditProfileWidgets {
  final SettingsProfileModel profile;
  final TextEditingController nameController;
  final TextEditingController emailController;

  EditProfileView({super.key, required this.profile})
    : nameController = TextEditingController(text: profile.name),
      emailController = TextEditingController(
        text: FirebaseAuth.instance.currentUser?.email ?? '',
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileViewModel(
        name: profile.name,
        photoUrl: profile.photoUrl,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<EditProfileViewModel, EditProfileState>(
            listenWhen: (previous, current) =>
                !previous.nameSaved && current.nameSaved,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İsim güncellendi')),
              );
            },
          ),
          BlocListener<EditProfileViewModel, EditProfileState>(
            listenWhen: (previous, current) =>
                previous.status != ViewStatus.failure &&
                current.status == ViewStatus.failure,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Bir hata oluştu')),
              );
            },
          ),
          BlocListener<EditProfileViewModel, EditProfileState>(
            listenWhen: (previous, current) =>
                !previous.accountDeleted && current.accountDeleted,
            listener: (context, state) {
              context.router.replaceAll([LoginViewRoute()]);
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: context.cBackground,
          appBar: AppBar(
            backgroundColor: context.cBackground,
            leading: const BackButton(),
            title: Text('Profili Düzenle', style: context.titleLarge),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: context.paddingNormal,
              child: BlocBuilder<EditProfileViewModel, EditProfileState>(
                builder: (context, state) {
                  final viewModel = context.read<EditProfileViewModel>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      avatar(
                        context,
                        photoUrl: state.photoUrl,
                        isUploading: state.isUploadingPhoto,
                        onTap: () => _pickPhoto(context, viewModel),
                      ),
                      context.sizedHeightBoxMedium,
                      AuthTextField(
                        controller: nameController,
                        label: 'İsim',
                        hint: 'Adınız',
                        icon: Icons.person_outline,
                        onChanged: (v) =>
                            viewModel.add(EditProfileNameChangedEvent(v)),
                      ),
                      context.sizedHeightBoxNormal,
                      AuthTextField(
                        controller: emailController,
                        label: 'E-posta',
                        hint: 'E-posta',
                        icon: Icons.email_outlined,
                        enabled: false,
                      ),
                      context.sizedHeightBoxMedium,
                      PrimaryButton(
                        label: 'Kaydet',
                        onPressed: () =>
                            viewModel.add(EditProfileNameSavedEvent()),
                      ),
                      context.sizedHeightBoxMedium,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            context.router.replaceAll([LoginViewRoute()]);
                          }
                        },
                        child: const Text('Çıkış Yap'),
                      ),
                      context.sizedHeightBoxNormal,
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => _confirmDeleteAccount(context, viewModel),
                        child: const Text('Hesabı Sil'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _pickPhoto(
  BuildContext context,
  EditProfileViewModel viewModel,
) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) {
      return EditProfilePhotoSheetWidget.photoSourceSheet(
        sheetContext,
        onGallery: () => Navigator.pop(sheetContext, ImageSource.gallery),
        onCamera: () => Navigator.pop(sheetContext, ImageSource.camera),
      );
    },
  );

  if (source == null) return;

  final pickedFile = await ImagePicker().pickImage(
    source: source,
    imageQuality: 80,
  );
  if (pickedFile == null) return;

  if (context.mounted) {
    viewModel.add(EditProfilePhotoPickedEvent(File(pickedFile.path)));
  }
}

Future<void> _confirmDeleteAccount(
  BuildContext context,
  EditProfileViewModel viewModel,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Sil',
              style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    viewModel.add(EditProfileDeleteAccountRequestedEvent());
  }
}
