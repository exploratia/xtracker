import 'package:flutter/material.dart';

import '../../../screens/administration/log_screen.dart';
import '../../../util/logging/daily_files.dart';
import '../../card/settings_card.dart';
import '../../layout/single_child_scroll_view_with_scrollbar.dart';

class LogsView extends StatefulWidget {
  ///
  /// logSelectHandler - callback which gets logFileName as parameter and rebuild logsView-Function to rebuild logs if e.g. a log was deleted
  const LogsView({super.key, required this.logSelectHandler});

  final void Function(String logFileName, VoidCallback rebuildLogsView)
      logSelectHandler;

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
      onRefreshCallback: () async {
        _rebuild();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SettingsCard(
            showDivider: false,
            children: [
              FutureBuilder(
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  } else if (snapshot.hasError) {
                    // .. do error handling
                    return Center(
                        child: Text(
                            'Failed to load logs! ${snapshot.error?.toString() ?? ''}'));
                  }
                  final logFiles = snapshot.data;
                  if (logFiles == null) {
                    return const Center(child: Text('No log files found...'));
                  }

                  return Center(
                    child: Wrap(
                      spacing: 20,
                      children: [
                        ...logFiles.map((logFile) => _Chip(logFile,
                            () => widget.logSelectHandler(logFile, _rebuild)))
                      ],
                    ),
                  );
                },
                future: DailyFiles.listLogFileNames(),
              ),
            ],
          ),
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
      avatar: Icon(LogScreen.navItem.icon.icon,
          color: Theme.of(context).colorScheme.primary),
      label: Text(logFileName.replaceAll('.txt', '')),
      onPressed: () => pressedHandler(),
    );
  }
}
