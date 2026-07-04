part of 'preferences_widget.dart';

mixin PreferencesModeCardWidget {
  static Widget modeCard(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required String image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: context.normalBorderRadius,
          border: Border.all(
            color: isSelected
                ? context.cPrimary
                : context.cPrimary.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.cPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.vertical(
                    top: context.normalRadius,
                  ),
                ),
                child: Image.asset(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: context.paddingLow,
              child: Text(
                label,
                style: context.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? context.cPrimary : context.cTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
