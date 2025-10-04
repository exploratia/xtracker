import 'package:flutter/material.dart';

import '../../../util/theme_utils.dart';

class ValidationField extends FormField<bool> {
  ValidationField({
    super.key,
    required bool Function() validatorCondition,
    String errorMessage = "Invalid",
  }) : super(
          validator: (value) {
            if (!validatorCondition()) {
              return errorMessage;
            }
            return null;
          },
          builder: (field) {
            final themeData = Theme.of(field.context);
            var inputDecorationTheme = themeData.inputDecorationTheme;

            return field.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: ThemeUtils.verticalSpacingSmall),
                      Container(
                        color: inputDecorationTheme.errorBorder?.borderSide.color,
                        height: 2,
                      ),
                      const SizedBox(height: ThemeUtils.defaultPadding),
                      Text(
                        field.errorText!,
                        style: inputDecorationTheme.errorStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : const SizedBox.shrink();
          },
        );
}
