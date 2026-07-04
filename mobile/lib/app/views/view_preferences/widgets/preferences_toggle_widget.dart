part of 'preferences_widget.dart';

mixin PreferencesToggleWidget {
  static Widget toggleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: context.bodyMedium),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: context.cPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
