part of 'preferences_widget.dart';

mixin PreferencesPageTwoWidget {
  static Widget pageTwo(
    BuildContext context, {
    required String? selectedMode,
    required double budget,
    required bool smokingArea,
    required bool alcoholService,

    required ValueChanged<String> onSelectMode,
    required ValueChanged<double> onBudgetChanged,
    required ValueChanged<bool> onSmokingChanged,
    required ValueChanged<bool> onAlcoholChanged,
    required VoidCallback onSubmit,
  }) {
    return SingleChildScrollView(
      padding: context.paddingNormal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Günlük Modun Nedir?', style: context.headlineMedium),
          context.sizedHeightBoxLow,
          Text(
            'Bugünü nasıl hissediyorsun? Sana en uygun mekanları listeleyelim.',
            style: context.bodyMedium,
          ),
          context.sizedHeightBoxNormal,
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: PreferenceConstants.dailyModes.map((mode) {
              return PreferencesModeCardWidget.modeCard(
                context,
                label: mode,
                image: PreferenceConstants.dailyModeImages[mode]!,
                isSelected: selectedMode == mode,
                onTap: () => onSelectMode(mode),
              );
            }).toList(),
          ),
          context.sizedHeightBoxMedium,
          PreferencesBudgetWidget.budgetSlider(
            context,
            budget: budget,
            onChanged: onBudgetChanged,
          ),
          context.sizedHeightBoxMedium,
          PreferencesToggleWidget.toggleRow(
            context,
            icon: Icons.smoking_rooms_outlined,
            title: 'Sigara İçilen Alan',
            subtitle: 'Açık hava veya balkon tercihi',
            value: smokingArea,
            onChanged: onSmokingChanged,
          ),
          PreferencesToggleWidget.toggleRow(
            context,
            icon: Icons.local_bar_outlined,
            title: 'Alkol Servisi',
            subtitle: 'Mekanda alkollü içecekler olsun',
            value: alcoholService,
            onChanged: onAlcoholChanged,
          ),
          context.sizedHeightBoxMedium,
          PrimaryButton(label: 'Kaydet', onPressed: onSubmit),
        ],
      ),
    );
  }
}
