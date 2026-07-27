part of 'settings_widgets.dart';

mixin SettingsStatItemWidget {
  static Widget statItem(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: context.bodyMedium),
      ],
    );
  }
}
