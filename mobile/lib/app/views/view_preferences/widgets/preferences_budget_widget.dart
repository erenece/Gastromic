part of 'preferences_widget.dart';

mixin PreferencesBudgetWidget {
  static Widget budgetSlider(
    BuildContext context, {
    required double budget,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kişi Başı Bütçe', style: context.titleLarge),
            Container(
              padding: context.horizontalPaddingConstLow,
              decoration: BoxDecoration(
                color: context.cPrimary,
                borderRadius: context.lowBorderRadius,
              ),
              child: Text(
                '${budget.toInt()} ₺',
                style: context.bodyMedium.copyWith(color: context.cSurface),
              ),
            ),
          ],
        ),
        Slider(
          value: budget,
          min: PreferenceConstants.minBudget,
          max: PreferenceConstants.maxBudget,
          divisions: 59,
          activeColor: context.cPrimary,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${PreferenceConstants.minBudget.toInt()} ₺',
              style: context.bodyMedium,
            ),
            Text(
              '${PreferenceConstants.maxBudget.toInt()} ₺',
              style: context.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
