part of 'settings_widgets.dart';

mixin SettingsThemeSheetWidget {
  static Widget themeSheet(
    BuildContext context, {
    required ThemeMode current,
    required ValueChanged<ThemeMode> onSelected,
  }) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(
            context,
            label: 'Sistem',
            mode: ThemeMode.system,
            current: current,
            onSelected: onSelected,
          ),
          _option(
            context,
            label: 'Açık',
            mode: ThemeMode.light,
            current: current,
            onSelected: onSelected,
          ),
          _option(
            context,
            label: 'Koyu',
            mode: ThemeMode.dark,
            current: current,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }

  static Widget _option(
    BuildContext context, {
    required String label,
    required ThemeMode mode,
    required ThemeMode current,
    required ValueChanged<ThemeMode> onSelected,
  }) {
    return ListTile(
      title: Text(label),
      trailing: current == mode
          ? Icon(Icons.check, color: context.cPrimary)
          : null,
      onTap: () => onSelected(mode),
    );
  }
}
