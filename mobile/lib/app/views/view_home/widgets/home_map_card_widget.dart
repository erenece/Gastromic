part of 'home_widgets.dart';

mixin HomeMapCardWidget {
  static Widget mapCard(
    BuildContext context, {
    required VoidCallback onExplore,
  }) {
    return ClipRRect(
      borderRadius: context.normalBorderRadius,
      child: SizedBox(
        height: context.dynamicHeight(0.22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // google maps entegrasyonu gelecek
            Container(
              color: context.cPrimary.withValues(alpha: 0.08),
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 40,
                  color: context.cPrimary.withValues(alpha: 0.3),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Haritayı Keşfet',
                          style: context.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Yakınınızdaki en iyi lezzetleri bulun',
                          style: context.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  context.sizedWidthBoxLow,
                  GestureDetector(
                    onTap: onExplore,
                    child: Container(
                      padding: context.horizontalPaddingConstNormalVertical14,
                      decoration: BoxDecoration(
                        color: context.cPrimary,
                        borderRadius: context.mediumBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 16,
                            color: Colors.white,
                          ),
                          context.sizedWidthBoxLow,
                          Text(
                            'Bul',
                            style: context.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
