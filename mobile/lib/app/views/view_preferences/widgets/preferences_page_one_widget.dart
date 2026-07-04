part of 'preferences_widget.dart';

mixin PreferencesPageOneWidget {
  static Widget pageOne(
    BuildContext context, {
    required Set<String> selectedAllergens,
    required Set<String> selectedConditions,
    required ValueChanged<String> onToggleAllergen,
    required ValueChanged<String> onToggleCondition,
    required VoidCallback onNext,
  }) {
    return SingleChildScrollView(
      padding: context.paddingNormal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Genel Tercihler', style: context.headlineMedium),
          context.sizedHeightBoxLow,
          Text(
            'Size en uygun menüleri önerebilmemiz için alerji ve sağlık durumlarınızı seçin.',
            style: context.bodyMedium,
          ),
          context.sizedHeightBoxMedium,
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: context.cPrimary),
              context.sizedWidthBoxLow,
              Text('Alerjiler', style: context.titleLarge),
            ],
          ),
          context.sizedHeightBoxNormal,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PreferenceConstants.allergens.map((allergen) {
              return PreferencesChipWidget.selectableChip(
                context,
                label: allergen,
                isSelected: selectedAllergens.contains(allergen),
                onTap: () => onToggleAllergen(allergen),
              );
            }).toList(),
          ),
          context.sizedHeightBoxMedium,
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: context.cPrimary),
              context.sizedWidthBoxLow,
              Text('Hastalık & Hassasiyetler', style: context.titleLarge),
            ],
          ),
          context.sizedHeightBoxNormal,
          ...PreferenceConstants.conditions.map((condition) {
            final isSelected = selectedConditions.contains(condition);
            return Padding(
              padding: context.onlyBottomPaddingLow,
              child: GestureDetector(
                onTap: () => onToggleCondition(condition),
                child: Container(
                  width: double.infinity,
                  padding: context.paddingNormal,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.cPrimary.withValues(alpha: 0.15)
                        : context.cSurface,
                    borderRadius: context.normalBorderRadius,
                    border: Border.all(
                      color: isSelected
                          ? context.cPrimary
                          : context.cPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    condition,
                    style: context.bodyMedium.copyWith(
                      color: isSelected
                          ? context.cPrimary
                          : context.cTextPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
          context.sizedHeightBoxMedium,
          PrimaryButton(label: 'Sonraki Adım', onPressed: onNext),
        ],
      ),
    );
  }
}
