part of 'search_widgets.dart';

mixin SearchBarWidget {
  static Widget searchBar(
    BuildContext context, {
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onFilterTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Ne arıyorsun?',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: context.cSurface,
              border: OutlineInputBorder(
                borderRadius: context.normalBorderRadius,
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        context.sizedWidthBoxLow,
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: context.paddingLow2x,
            decoration: BoxDecoration(
              color: context.cSurface,
              borderRadius: context.normalBorderRadius,
            ),
            child: Icon(Icons.tune, color: context.cPrimary),
          ),
        ),
      ],
    );
  }
}
