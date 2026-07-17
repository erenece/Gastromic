part of 'venue_detail_widgets.dart';

mixin VenueDetailDishesWidget {
  static Widget dishes(
    BuildContext context, {
    required List<DishModel> dishes,
  }) {
    if (dishes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Önerilen Lezzetler', style: context.titleLarge),
        context.sizedHeightBoxNormal,
        SizedBox(
          height: context.dynamicHeight(0.28),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            separatorBuilder: (_, __) => context.sizedWidthBoxLow2x,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return SizedBox(
                width: context.dynamicWidth(0.42),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: context.mediumBorderRadius,
                        child: dish.imageUrl.isNotEmpty
                            ? Image.network(
                                dish.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                color: context.cPrimary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: context.cPrimary.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    context.sizedHeightBoxLow,
                    Text(
                      dish.name,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dish.description,
                      style: context.bodyMedium.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
