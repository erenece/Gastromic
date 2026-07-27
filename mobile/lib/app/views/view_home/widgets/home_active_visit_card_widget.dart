part of 'home_widgets.dart';

mixin HomeActiveVisitCardWidget {
  static Widget activeVisitCard(
    BuildContext context, {
    required PendingVisitModel visit,
    required VoidCallback onRateTap,
  }) {
    return Container(
      width: double.infinity,
      padding: context.paddingNormal,
      decoration: BoxDecoration(
        color: context.cSecondary.withValues(alpha: 0.1),
        borderRadius: context.normalBorderRadius,
        border: Border.all(color: context.cSecondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: context.cSecondary),
              context.sizedWidthBoxLow,
              Expanded(
                child: Text(
                  'Şu an buradasınız',
                  style: context.bodyMedium.copyWith(
                    color: context.cSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          context.sizedHeightBoxLow,
          Text(
            visit.venueName,
            style: context.titleLarge.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (visit.location.isNotEmpty) ...[
            context.sizedHeightBoxLow,
            Text(
              visit.location,
              style: context.bodyMedium.copyWith(
                color: context.cTextPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
          context.sizedHeightBoxNormal,
          PrimaryButton(label: 'Puan Ver', onPressed: onRateTap),
        ],
      ),
    );
  }
}
