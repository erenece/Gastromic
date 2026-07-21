part of 'settings_widgets.dart';

mixin SettingsRowWidget {
  static Widget settingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: context.paddingNormal,
        margin: context.onlyBottomPaddingLow,
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: context.normalBorderRadius,
        ),
        child: Row(
          children: [
            Icon(icon, color: context.cPrimary),
            context.sizedWidthBoxNormal,
            Expanded(
              child: Text(
                title,
                style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
