part of 'operation_widgets.dart';

mixin OperationMapWidget {
  static Widget mapArea(
    BuildContext context, {
    required List<MapVenueModel> venues,
    required String? selectedVenueId,
    required ValueChanged<String> onPinTap,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: context.cPrimary.withValues(alpha: 0.06),
            child: Center(
              child: Icon(
                Icons.map_outlined,
                size: 48,
                color: context.cPrimary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        ...List.generate(venues.length, (index) {
          final venue = venues[index];
          final isSelected = venue.id == selectedVenueId;
          final positions = _placeholderPositions(context);
          final pos = positions[index % positions.length];
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            child: GestureDetector(
              onTap: () => onPinTap(venue.id),
              child: Transform.rotate(
                angle: 0.785398,
                child: Container(
                  width: isSelected ? 26 : 20,
                  height: isSelected ? 26 : 20,
                  decoration: BoxDecoration(
                    color: context.cPrimary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          );
        }),
        Positioned(
          left: context.width * 0.4,
          top: context.dynamicHeight(0.22),
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: context.cSecondary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  static List<Offset> _placeholderPositions(BuildContext context) {
    final w = context.width;
    final h = context.dynamicHeight(0.5);
    return [
      Offset(w * 0.25, h * 0.3),
      Offset(w * 0.6, h * 0.35),
      Offset(w * 0.3, h * 0.55),
      Offset(w * 0.65, h * 0.6),
      Offset(w * 0.45, h * 0.45),
    ];
  }
}
