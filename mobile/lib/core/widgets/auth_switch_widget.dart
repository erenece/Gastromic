import 'package:flutter/material.dart';

import 'package:gastromic/core/extensions/core_extensions.dart';

class AuthSwitchWidget extends StatelessWidget {
  final String questionText;
  final String linkLabel;
  final VoidCallback onLinkPressed;

  const AuthSwitchWidget({
    super.key,
    required this.questionText,
    required this.linkLabel,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(questionText, style: context.bodyMedium),
        GestureDetector(
          onTap: onLinkPressed,
          child: Text(
            linkLabel,
            style: context.labelLarge.copyWith(
              color: context.cPrimary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
