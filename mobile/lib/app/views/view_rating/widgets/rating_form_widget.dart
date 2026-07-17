part of 'rating_widgets.dart';

mixin RatingFormWidget {
  static Widget ratingForm(
    BuildContext context, {
    required PendingVisitModel visit,
    required double starRating,
    required TextEditingController commentController,
    required bool canSubmit,
    required bool isLoading,
    required ValueChanged<double> onStarChanged,
    required ValueChanged<String> onCommentChanged,
    required VoidCallback onSubmit,
    required VoidCallback onClose,
  }) {
    return Container(
      margin: context.onlyBottomPaddingNormal,
      padding: context.paddingNormal,
      decoration: BoxDecoration(
        color: context.cSurface,
        borderRadius: context.normalBorderRadius,
        border: Border.all(color: context.cPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  visit.venueName,
                  style: context.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 20, color: context.cTextPrimary),
              ),
            ],
          ),
          context.sizedHeightBoxNormal,
          Text('Deneyiminizi puanlayın', style: context.bodyMedium),
          context.sizedHeightBoxLow,
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return GestureDetector(
                onTap: () => onStarChanged(star.toDouble()),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    star <= starRating ? Icons.star : Icons.star_border,
                    size: 32,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          ),
          context.sizedHeightBoxNormal,
          TextField(
            controller: commentController,
            onChanged: onCommentChanged,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Yorumunuz (opsiyonel)',
              filled: true,
              fillColor: context.cBackground,
              border: OutlineInputBorder(
                borderRadius: context.mediumBorderRadius,
                borderSide: BorderSide.none,
              ),
            ),
          ),
          context.sizedHeightBoxNormal,
          PrimaryButton(
            label: isLoading ? 'Gönderiliyor...' : 'Gönder',
            onPressed: (canSubmit && !isLoading) ? onSubmit : () {},
          ),
        ],
      ),
    );
  }
}
