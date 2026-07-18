part of 'operation_widgets.dart';

mixin OperationFiltersWidget {
  static Widget filters(
    BuildContext context, {
    required RangeValues priceRange,
    required double busynessThreshold,
    required bool openNowOnly,
    required ValueChanged<RangeValues> onPriceChanged,
    required ValueChanged<double> onBusynessChanged,
    required ValueChanged<bool> onOpenNowChanged,
  }) {
    return Container(
      padding: context.paddingNormal,
      decoration: BoxDecoration(
        color: context.cBackground,
        borderRadius: BorderRadius.vertical(top: context.normalRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Arama Kriterleri', style: context.titleLarge),
          context.sizedHeightBoxNormal,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fiyat Bilgisi', style: context.titleLarge),
              Container(
                padding: context.horizontalPaddingConstLow,
                decoration: BoxDecoration(
                  color: context.cPrimary,
                  borderRadius: context.lowBorderRadius,
                ),
                child: Text(
                  '${priceRange.start.toInt()}₺ - ${priceRange.end.toInt()}₺',
                  style: context.bodyMedium.copyWith(color: context.cSurface),
                ),
              ),
            ],
          ),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 3000,
            divisions: 60,
            activeColor: context.cPrimary,
            onChanged: onPriceChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 ₺', style: context.bodyMedium),
              Text('3000 ₺', style: context.bodyMedium),
            ],
          ),

          context.sizedHeightBoxMedium,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yoğunluk Bilgisi', style: context.titleLarge),
              Container(
                padding: context.horizontalPaddingConstLow,
                decoration: BoxDecoration(
                  color: context.cPrimary,
                  borderRadius: context.lowBorderRadius,
                ),
                child: Text(
                  busynessThreshold < 0.4
                      ? 'Sakin'
                      : busynessThreshold < 0.7
                      ? 'Orta'
                      : 'Kalabalık',
                  style: context.bodyMedium.copyWith(color: context.cSurface),
                ),
              ),
            ],
          ),
          Slider(
            value: busynessThreshold,
            min: 0,
            max: 1,
            activeColor: context.cPrimary,
            onChanged: onBusynessChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sakin', style: context.bodyMedium),
              Text('Kalabalık', style: context.bodyMedium),
            ],
          ),

          context.sizedHeightBoxMedium,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Şu an açık olanlar', style: context.titleLarge),
              Switch(
                value: openNowOnly,
                activeColor: context.cPrimary,
                onChanged: onOpenNowChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
