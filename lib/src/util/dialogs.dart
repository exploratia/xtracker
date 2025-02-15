import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/responsive/device_dependent_constrained_box.dart';

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
              child: Text(buttonText ?? t.commonsDialogBtnOkay))
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
    final t = AppLocalizations.of(context);
    return Dialogs.simpleOkDialog(content, context, title: title ?? t!.commonsDialogTitleErrorOccurred);
  }

  /// returns true|false=null (null in case of back-tap)
  static Future<bool?> simpleYesNoDialog(
    dynamic content,
    BuildContext context, {
    dynamic title,
  }) async {
    final t = AppLocalizations.of(context)!;

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
            child: Text(t.commonsDialogBtnNo),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: Text(t.commonsDialogBtnYes),
          ),
        ],
      ),
    );
  }

  /// show [SnackBar]
  /// * [content] Widget or Text
  static void showSnackBar(dynamic content, BuildContext context, {Duration? duration, SnackBarAction? snackBarAction}) {
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

  static Widget? _contentWidget(content) {
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

  static Widget? _titleWidget(title) {
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
