part of 'edit_profile_widgets.dart';

mixin EditProfileAvatarWidget {
  static Widget avatar(
    BuildContext context, {
    required String photoUrl,
    required bool isUploading,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: isUploading ? null : onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            if (isUploading)
              Positioned.fill(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: const CircularProgressIndicator(color: Colors.white),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.cPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.cSurface, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
