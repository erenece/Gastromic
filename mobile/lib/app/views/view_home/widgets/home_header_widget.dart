part of 'home_widgets.dart';

mixin HomeHeaderWidget {
  static Widget header(BuildContext context, {required String locationName}) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 18, color: context.cPrimary),
        context.sizedWidthBoxLow,
        Text(
          locationName.isEmpty ? 'Konum alınıyor...' : locationName,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
