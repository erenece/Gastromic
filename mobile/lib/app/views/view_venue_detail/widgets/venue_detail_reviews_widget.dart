part of 'venue_detail_widgets.dart';

mixin VenueDetailReviewsWidget {
  static Widget reviews(
    BuildContext context, {
    required List<ReviewModel> reviews,
    required VoidCallback onSeeAll,
  }) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Değerlendirmeler', style: context.titleLarge),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'Tümünü Gör',
                style: context.bodyMedium.copyWith(color: context.cPrimary),
              ),
            ),
          ],
        ),
        context.sizedHeightBoxNormal,
        ...reviews.map((review) {
          return Container(
            width: double.infinity,
            margin: context.onlyBottomPaddingLow,
            padding: context.paddingNormal,
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: context.normalBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: context.cPrimary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            review.userName.isNotEmpty
                                ? review.userName[0]
                                : '?',
                            style: context.bodyMedium.copyWith(
                              color: context.cPrimary,
                            ),
                          ),
                        ),
                        context.sizedWidthBoxLow,
                        Text(
                          review.userName,
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < review.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                context.sizedHeightBoxLow,
                Text(review.comment, style: context.bodyMedium),
                context.sizedHeightBoxLow,
                Text(
                  review.date,
                  style: context.bodyMedium.copyWith(fontSize: 11),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
