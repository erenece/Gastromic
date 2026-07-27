part of 'rating_widgets.dart';

mixin RatingHistoryWidget {
  static Widget historySection(
    BuildContext context, {
    required List<UserReviewHistoryModel> reviews,
  }) {
    if (reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geçmiş Değerlendirmeler', style: context.titleLarge),
        context.sizedHeightBoxNormal,
        ...reviews.map((review) {
          return Container(
            width: double.infinity,
            margin: context.onlyBottomPaddingNormal,
            padding: context.paddingNormal,
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: context.normalBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.venueName,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                context.sizedHeightBoxLow,
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    );
                  }),
                ),
                if (review.comment.isNotEmpty) ...[
                  context.sizedHeightBoxLow,
                  Text(review.comment, style: context.bodyMedium),
                ],
                if (review.date.isNotEmpty) ...[
                  context.sizedHeightBoxLow,
                  Text(
                    review.date,
                    style: context.bodyMedium.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
