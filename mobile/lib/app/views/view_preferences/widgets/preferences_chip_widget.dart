part of 'preferences_widget.dart';

mixin PreferencesChipWidget {
  static Widget selectableChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.horizontalPaddingConstNormalVertical14,
        decoration: BoxDecoration(
          color: isSelected
              ? context.cPrimary.withValues(alpha: 0.15)
              : context.cSurface,
          borderRadius: context.mediumBorderRadius,
          border: Border.all(
            color: isSelected
                ? context.cPrimary
                : context.cPrimary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: context.bodyMedium.copyWith(
            color: isSelected ? context.cPrimary : context.cTextPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
