import 'package:flutter/material.dart';

import 'package:gastromic/core/extensions/core_extensions.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.cPrimary,
          padding: context.verticalPaddingConstNormal,
          shape: RoundedRectangleBorder(
            borderRadius: context.normalBorderRadius,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(color: context.cSurface),
        ),
      ),
    );
  }
}
