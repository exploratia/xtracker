import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/assets.gen.dart';
import '../../../generated/locale_keys.g.dart';
import '../../util/globals.dart';
import '../../util/media_query_utils.dart';
import '../../util/theme_utils.dart';
import '../administration/settings/settings_controller.dart';
import '../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../controls/lnk/img_lnk.dart';
import '../controls/responsive/device_dependent_constrained_box.dart';

/// Check if a app support reminder should be displayed.
class AppSupportCheck extends StatefulWidget {
  final Widget child;
  final SettingsController settingsController;

  const AppSupportCheck({super.key, required this.child, required this.settingsController});

  @override
  State<AppSupportCheck> createState() => _AppSupportCheckState();
}

class _AppSupportCheckState extends State<AppSupportCheck> {
  @override
  void initState() {
    super.initState();

    var settingsController = widget.settingsController;
    DateTime reminderDate = settingsController.appSupportReminderDate;

    if (DateTime.now().isAfter(reminderDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAlert(context);
      });
    }
  }

  void _showAlert(BuildContext context) async {
    final settingsController = widget.settingsController;
    Widget dialogContent;

    var coffeeImg = Image(
      image: Assets.images.bmc.coffee.provider(),
      height: 100,
      width: 100,
    );
    var text = DateTime.now().difference(settingsController.initialAppStart).abs().inDays > 700
        ? Text(LocaleKeys.appSupport_multipleYearsMsg.tr())
        : Text(LocaleKeys.appSupport_oneYearMsg.tr());

    final mediaQueryUtils = MediaQueryUtils.of(context);
    var availableWidth = mediaQueryUtils.mediaQueryData.size.width;
    if (availableWidth < 400) {
      dialogContent = SingleChildScrollViewWithScrollbar(
        useScreenPadding: false,
        useHorizontalScreenPaddingForScrollbar: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: ThemeUtils.verticalSpacing,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            text,
            coffeeImg,
          ],
        ),
      );
    } else {
      dialogContent = SizedBox(
        width: min(availableWidth - ThemeUtils.screenPadding, DeviceDependentWidthConstrainedBox.tabletMaxWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            coffeeImg,
            Expanded(
              child: SingleChildScrollViewWithScrollbar(
                useScreenPadding: false,
                useHorizontalScreenPaddingForScrollbar: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: ThemeUtils.verticalSpacing,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    text,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleKeys.appSupport_title.tr()),
        content: dialogContent,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(LocaleKeys.commons_dialog_btn_close.tr()),
          ),
          ImgLnk(uri: Globals.urlCoffeeExploratia, imageProvider: Assets.images.bmc.bmcButton.provider(), height: 48, width: 171),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
    );

    // update next reminder date
    await settingsController.updateAppSupportReminderDate();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
