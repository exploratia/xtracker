import 'package:flutter/material.dart';

import '../../../screens/administration/log_screen.dart';
import '../../../util/logging/daily_files.dart';
import '../../controls/card/settings_card.dart';
import '../../controls/future/future_builder_with_progress_indicator.dart';
import '../../controls/layout/scroll_footer.dart';
import '../../controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../controls/navigation/hide_bottom_navigation_bar.dart';

class LogsView extends StatefulWidget {
  ///
  /// logSelectHandler - callback which gets logFileName as parameter and rebuild logsView-Function to rebuild logs if e.g. a log was deleted
  const LogsView({super.key, required this.logSelectHandler});

  final void Function(String logFileName, VoidCallback rebuildLogsView) logSelectHandler;

  @override
  State<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends State<LogsView> {
  void _rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollViewWithScrollbar(
      useScreenPadding: true,
      scrollPositionHandler: HideBottomNavigationBar.setScrollPosition,
      onRefreshCallback: () async {
        _rebuild();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SettingsCard(
            showDivider: false,
            children: [
              FutureBuilderWithProgressIndicator(
                future: DailyFiles.listLogFileNames(),
                errorBuilder: (error) => 'Failed to load logs!',
                widgetBuilder: (logFiles, _) {
                  if (logFiles == null) {
                    return const Center(child: Text('No log files found!'));
                  }
                  return Center(
                    child: Wrap(
                      spacing: 20,
                      children: [...logFiles.map((logFile) => _Chip(logFile, () => widget.logSelectHandler(logFile, _rebuild)))],
                    ),
                  );
                },
              ),
            ],
          ),
          const Center(child: ScrollFooter()),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.logFileName, this.pressedHandler);

  final String logFileName;
  final VoidCallback pressedHandler;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        LogScreen.navItem.iconData,
        // size: ThemeUtils.iconSizeScaled,
      ),
      label: Text(logFileName.replaceAll('.txt', '')),
      onPressed: () => pressedHandler(),
    );
  }
}
