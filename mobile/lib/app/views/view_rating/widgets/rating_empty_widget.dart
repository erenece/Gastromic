part of 'rating_widgets.dart';

mixin RatingEmptyWidget {
  static Widget emptyState(BuildContext context) {
    return Padding(
      padding: context.paddingHigh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 48,
            color: context.cPrimary.withValues(alpha: 0.4),
          ),
          context.sizedHeightBoxNormal,
          Text(
            'Puanlanacak mekan yok',
            style: context.titleLarge,
            textAlign: TextAlign.center,
          ),
          context.sizedHeightBoxLow,
          Text(
            'Mekan detayından "Beni Götür" dediğiniz yerlere ulaştığınızda burada görünür.',
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
