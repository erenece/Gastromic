part of 'search_widgets.dart';

mixin SearchRecentWidget {
  static Widget recentSection(
    BuildContext context, {
    required List<String> recentSearches,
    required ValueChanged<String> onRecentTap,
    required VoidCallback onClear,
  }) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Son Aramalar', style: context.titleLarge),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Temizle',
                style: context.bodyMedium.copyWith(color: context.cPrimary),
              ),
            ),
          ],
        ),
        context.sizedHeightBoxLow,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((query) {
            return GestureDetector(
              onTap: () => onRecentTap(query),
              child: Container(
                padding: context.horizontalPaddingConstNormalVertical14,
                decoration: BoxDecoration(
                  color: context.cSurface,
                  borderRadius: context.mediumBorderRadius,
                  border: Border.all(
                    color: context.cPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 16, color: context.cPrimary),
                    context.sizedWidthBoxLow,
                    Text(query, style: context.bodyMedium),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
