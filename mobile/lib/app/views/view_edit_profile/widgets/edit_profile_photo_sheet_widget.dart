part of 'edit_profile_widgets.dart';

mixin EditProfilePhotoSheetWidget {
  static Widget photoSourceSheet(
    BuildContext context, {
    required VoidCallback onGallery,
    required VoidCallback onCamera,
  }) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Galeriden Seç'),
            onTap: onGallery,
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Fotoğraf Çek'),
            onTap: onCamera,
          ),
        ],
      ),
    );
  }
}
