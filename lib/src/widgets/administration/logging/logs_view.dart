import 'package:flutter/material.dart';

import '../../../util/logging/daily_files.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder(
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              } else if (snapshot.hasError) {
                // .. do error handling
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        'Failed to load logs! ${snapshot.error?.toString() ?? ''}'),
                  ),
                );
              }
              final logFiles = snapshot.data;
              if (logFiles == null) {
                return const Center(
                  child: Text('No log files found...'),
                );
              }
              return SingleChildScrollViewWithScrollbar(
                onRefreshCallback: () async {
                  _rebuild();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      children: [
                        ...logFiles.map((logFile) => _Chip(logFile,
                            () => widget.logSelectHandler(logFile, _rebuild)))
                      ],
                    ),
                  ),
                ),
              );
            },
            future: DailyFiles.listLogFileNames(),
          ),
        ),
      ],
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
      avatar: Icon(Icons.short_text_outlined,
          color: Theme.of(context).colorScheme.primary),
      label: Text(logFileName.replaceAll('.txt', '')),
      onPressed: () => pressedHandler(),
    );
  }
}
