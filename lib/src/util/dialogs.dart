import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context)!;

    Widget? titleWidget;
    if (title != null) {
      if (title is String) {
        titleWidget = Text(title);
      } else if (title is Widget) {
        titleWidget = title;
      }
    }

    Widget? contentWidget;
    if (content != null) {
      if (content is String) {
        contentWidget = Text(content);
      } else if (content is Widget) {
        contentWidget = content;
      } else {
        contentWidget = const Icon(Icons.question_mark_outlined);
      }
    }

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
              child: Text(buttonText ?? t.commonsDialogBtnOkay))
        ],
      ),
    );
  }

  static Future<void> simpleErrOkDialog(
    String text,
    BuildContext context, {
    String? title,
    String? buttonText,
  }) async {
    final t = AppLocalizations.of(context);
    return Dialogs.simpleOkDialog(text, context,
        title: title ?? t!.commonsDialogTitleErrorOccurred);
  }

  /// show [SnackBar]
  /// * [content] Widget or Text
  static void showSnackBar(dynamic content, BuildContext context,
      {Duration? duration, SnackBarAction? snackBarAction}) {
    Duration d = duration ?? const Duration(seconds: 2);
    Widget c = (content is Widget)
        ? content
        : (content is String)
            ? Text(content)
            : const Text('invalid content given');
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: c,
        duration: d,
        action: snackBarAction,
        // behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
