import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../widgets/controls/responsive/device_dependent_constrained_box.dart';
import 'theme_utils.dart';

class Dialogs {
  /// Dismiss | hide | remove OnScreenKeyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<void> simpleOkDialog(
    dynamic content,
    BuildContext context, {
    dynamic title,
    String? buttonText,
  }) async {
    Widget? titleWidget = _titleWidget(title);

    Widget? contentWidget = _contentWidget(content);

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: titleWidget,
        content: contentWidget,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(buttonText ?? LocaleKeys.commons_dialog_btn_okay.tr()))
        ],
      ),
    );
  }

  static Future<void> simpleErrOkDialog(
    dynamic content,
    BuildContext context, {
    dynamic title,
    String? buttonText,
  }) async {
    return Dialogs.simpleOkDialog(content, context, title: title ?? LocaleKeys.commons_dialog_title_errorOccurred.tr());
  }

  /// returns true|false=null (null in case of back-tap)
  static Future<bool?> simpleYesNoDialog(
    dynamic content,
    BuildContext context, {
    dynamic title,
  }) async {
    Widget? titleWidget = _titleWidget(title);

    Widget? contentWidget = _contentWidget(content);

    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: titleWidget,
        content: contentWidget,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
            },
            child: Text(LocaleKeys.commons_dialog_btn_no.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text(LocaleKeys.commons_dialog_btn_yes.tr()),
          ),
        ],
      ),
    );
  }

  /// Shows a generic selection dialog.
  ///
  /// [context] - BuildContext
  /// [title] - Title of the dialog
  /// [values] - List of possible values
  /// [itemBuilder] - Function that creates a widget for each value
  ///
  /// Returns the selected value or `null` if canceled.
  static Future<T?> showSelectionDialog<T>({
    required BuildContext context,
    required dynamic title,
    required List<T> values,
    required Widget Function(BuildContext context, T value) itemBuilder,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: _titleWidget(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollViewWithScrollbar(
              child: Column(
                spacing: ThemeUtils.verticalSpacingSmall,
                children: [
                  ...values.map(
                    (value) => InkWell(
                      borderRadius: ThemeUtils.borderRadiusCircularSmall,
                      onTap: () => Navigator.of(context).pop(value),
                      child: Padding(
                        padding: const EdgeInsets.all(ThemeUtils.paddingSmall),
                        child: itemBuilder(context, value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(LocaleKeys.commons_dialog_btn_cancel.tr()),
            ),
          ],
        );
      },
    );
  }

  /// show [SnackBar]
  /// * [content] Widget or Text
  static void showSnackBar(dynamic content, BuildContext context, {Duration? duration, SnackBarAction? snackBarAction, Color? color}) {
    Duration d = duration ?? const Duration(seconds: 2);
    Widget c = (content is Widget)
        ? content
        : (content is String)
            ? Text(
                content,
                style: TextStyle(color: color),
              )
            : const Text('invalid content given');
    var scaffoldMessengerState = ScaffoldMessenger.of(context);
    scaffoldMessengerState.hideCurrentSnackBar();
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        content: c,
        duration: d,
        action: snackBarAction,
        // behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSnackBarWarning(String content, BuildContext context, {Duration? duration, SnackBarAction? snackBarAction}) {
    showSnackBar('⚠  $content', context, color: Colors.orange, duration: duration);
  }

  static Widget? _contentWidget(dynamic content) {
    Widget? contentWidget;
    if (content != null) {
      if (content is String) {
        contentWidget = DeviceDependentWidthConstrainedBox(child: Text(content));
      } else if (content is Widget) {
        contentWidget = content;
      } else {
        contentWidget = const Icon(Icons.question_mark_outlined);
      }
    }
    return contentWidget;
  }

  static Widget? _titleWidget(dynamic title) {
    Widget? titleWidget;
    if (title != null) {
      if (title is String) {
        titleWidget = Text(title);
      } else if (title is Widget) {
        titleWidget = title;
      }
    }
    return titleWidget;
  }
}
